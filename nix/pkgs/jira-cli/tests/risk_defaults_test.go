package create

import (
	"bytes"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/ankitpokhrel/jira-cli/internal/cmdcommon"
	"github.com/ankitpokhrel/jira-cli/pkg/jira"
	"github.com/spf13/viper"
)

func TestConfirmWithoutEpic(t *testing.T) {
	for _, answer := range []string{"y\n", "yes\n", " YES \r\n", "n\n", "\n", "sure\n", "", "yes"} {
		var output bytes.Buffer
		err := confirmWithoutEpic(strings.NewReader(answer), &output)
		wantYes := answer == "y\n" || answer == "yes\n" || answer == " YES \r\n"
		if (err == nil) != wantYes {
			t.Errorf("answer=%q error=%v", answer, err)
		}
		if !strings.Contains(output.String(), "Warning: most tickets should belong to an epic.") || !strings.Contains(output.String(), "[y/N]") {
			t.Errorf("missing warning or default-no prompt: %q", output.String())
		}
	}
}

func TestEpicPolicy(t *testing.T) {
	viper.Set("project.key", "RD")
	defer viper.Reset()
	for _, tc := range []struct {
		name, kind, parent, field  string
		noEpic, subtask, wantError bool
	}{
		{"missing", "Bug", "", "customfield_10452", false, false, true},
		{"linked", "Bug", "3534", "customfield_10452", false, false, false},
		{"explicit opt out", "Bug", "", "", true, false, false},
		{"contradictory", "Bug", "RD-3534", "customfield_10452", true, false, true},
		{"unconfigured", "Bug", "RD-3534", "", false, false, true},
		{"whitespace", "Bug", " ", "customfield_10452", false, false, true},
		{"subtask missing", "Sub-task", "", "customfield_10452", true, true, true},
		{"subtask parent", "Sub-task", "3534", "customfield_10452", false, true, false},
		{"subtask handle", "child", "3534", "customfield_10452", false, true, false},
		{"epic", "Epic", "", "", true, false, true},
		{"unknown", "Typo", "", "", true, false, true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			cc := createCmd{
				params:     &cmdcommon.CreateParams{IssueType: tc.kind, ParentIssueKey: tc.parent},
				issueTypes: []*jira.IssueType{{Name: "Bug"}, {Name: "Sub-task", Handle: "child", Subtask: true}},
			}
			subtask, err := cc.validateEpic(tc.noEpic, "classic", tc.field)
			if (err != nil) != tc.wantError {
				t.Fatalf("error = %v", err)
			}
			if err == nil && subtask != tc.subtask {
				t.Fatalf("subtask = %v", subtask)
			}
			if err == nil && tc.parent == "3534" && cc.params.ParentIssueKey != "RD-3534" {
				t.Fatal("parent not normalized")
			}
		})
	}
}

func TestEpicCustomFieldCannotOverrideParent(t *testing.T) {
	viper.Set("issue.fields.custom", []map[string]interface{}{{"name": "Epic Link", "key": "customfield_10452"}})
	defer viper.Reset()
	cc := createCmd{params: &cmdcommon.CreateParams{IssueType: "Bug", ParentIssueKey: "RD-3534", CustomFields: map[string]string{"epic-link": ""}}, issueTypes: []*jira.IssueType{{Name: "Bug"}}}
	if _, err := cc.validateEpic(false, "classic", "customfield_10452"); err == nil {
		t.Fatal("custom field can override required epic")
	}
}

func TestNextGenSubtaskInheritance(t *testing.T) {
	viper.Set("project.type", jira.ProjectTypeNextGen)
	defer viper.Reset()
	for _, parent := range []string{`null`, `{"key":"RD-EPIC"}`} {
		server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if r.URL.Query().Get("jql") != `key = "RD-123" AND sprint = 343` {
				t.Errorf("query = %s", r.URL.Query().Get("jql"))
			}
			fmt.Fprintf(w, `{"issues":[{"key":"RD-123","fields":{"parent":%s}}]}`, parent)
		}))
		cc := createCmd{client: jira.NewClient(jira.Config{Server: server.URL}), params: &cmdcommon.CreateParams{ParentIssueKey: "RD-123"}}
		if err := cc.validateSubtask(343, false); (err == nil) != (parent != "null") {
			t.Errorf("parent=%s error=%v", parent, err)
		}
		server.Close()
	}
}

func TestResolveRiskSprint(t *testing.T) {
	for _, tc := range []struct {
		name, month, values string
		wantError           bool
	}{
		{"exact", "2026-11", `{"id":343,"name":"Risk-202611","state":"active"}`, false},
		{"wrong month", "2026-11", `{"id":343,"name":"Risk-202610","state":"active"}`, true},
		{"closed", "2026-11", `{"id":343,"name":"Risk-202611","state":"closed"}`, true},
		{"suffix", "2026-11", `{"id":343,"name":"Risk-202611-other","state":"active"}`, true},
		{"ambiguous", "2026-11", `{"id":343,"name":"Risk-202611","state":"active"},{"id":344,"name":"Risk-202611","state":"active"}`, true},
		{"december", "2026-12", `{"id":344,"name":"Risk-202612","state":"active"}`, false},
		{"january", "2027-01", `{"id":345,"name":"Risk-202701","state":"active"}`, false},
		{"missing", "2026-11", ``, true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				if r.URL.Path != "/rest/agile/1.0/board/84/sprint" || r.URL.Query().Get("state") != "active" {
					t.Errorf("unexpected request %s", r.URL)
				}
				fmt.Fprintf(w, `{"isLast":true,"values":[%s]}`, tc.values)
			}))
			defer server.Close()
			now, _ := time.Parse("2006-01", tc.month)
			id, err := resolveRiskSprint(jira.NewClient(jira.Config{Server: server.URL}), now)
			if (err != nil) != tc.wantError {
				t.Fatalf("id=%d error=%v", id, err)
			}
			if err == nil && id == 0 {
				t.Fatal("missing sprint ID")
			}
		})
	}
}

func TestResolveRiskSprintPaginationAndErrors(t *testing.T) {
	for _, mode := range []string{"later page", "stalled", "http error"} {
		t.Run(mode, func(t *testing.T) {
			calls := 0
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				calls++
				if mode == "http error" {
					http.Error(w, "unavailable", http.StatusServiceUnavailable)
					return
				}
				if mode == "stalled" {
					fmt.Fprint(w, `{"isLast":false,"startAt":0,"values":[]}`)
					return
				}
				if calls == 1 {
					fmt.Fprint(w, `{"isLast":false,"startAt":0,"values":[{"id":1,"name":"Other","state":"active"}]}`)
					return
				}
				if r.URL.Query().Get("startAt") != "1" {
					t.Errorf("unexpected pagination %s", r.URL)
				}
				fmt.Fprint(w, `{"isLast":true,"startAt":1,"values":[{"id":343,"name":"Risk-202611","state":"active"}]}`)
			}))
			defer server.Close()
			id, err := resolveRiskSprint(jira.NewClient(jira.Config{Server: server.URL}), time.Date(2026, 11, 12, 0, 0, 0, 0, time.UTC))
			if mode == "later page" {
				if err != nil || id != 343 || calls != 2 {
					t.Fatalf("id=%d calls=%d error=%v", id, calls, err)
				}
			} else if err == nil {
				t.Fatal("expected error")
			}
		})
	}
}

func TestSubtaskInheritance(t *testing.T) {
	viper.Set("epic.link", "customfield_10452")
	defer viper.Reset()
	for _, noEpic := range []bool{false, true} {
		for _, present := range []bool{false, true} {
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				want := `key = "RD-123" AND sprint = 343`
				if !noEpic {
					want += " AND cf[10452] is not EMPTY"
				}
				if r.URL.Query().Get("jql") != want {
					t.Errorf("query = %s", r.URL.Query().Get("jql"))
				}
				if present {
					fmt.Fprint(w, `{"issues":[{"key":"RD-123"}]}`)
				} else {
					fmt.Fprint(w, `{"issues":[]}`)
				}
			}))
			cc := createCmd{client: jira.NewClient(jira.Config{Server: server.URL}), params: &cmdcommon.CreateParams{ParentIssueKey: "RD-123"}}
			if err := cc.validateSubtask(343, noEpic); (err == nil) != present {
				t.Errorf("present=%v error=%v", present, err)
			}
			server.Close()
		}
	}
}
