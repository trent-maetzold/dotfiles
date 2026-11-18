package create

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"os/exec"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/spf13/viper"
)

func TestCreateCommandHelper(t *testing.T) {
	if os.Getenv("JIRA_CREATE_HELPER") != "1" {
		return
	}
	viper.Set("server", os.Getenv("JIRA_TEST_SERVER"))
	viper.Set("api_token", "mock-only")
	viper.Set("installation", "Local")
	if os.Getenv("JIRA_TEST_CLOUD") == "1" {
		viper.Set("installation", "Cloud")
	}
	viper.Set("project.type", "classic")
	viper.Set("epic.link", "customfield_10452")
	viper.Set("issue.types", []interface{}{
		map[string]interface{}{"id": "1", "name": "Bug", "subtask": false},
		map[string]interface{}{"id": "5", "name": "Sub-task", "subtask": true},
	})
	cmd := NewCmdCreate()
	SetFlags(cmd)
	cmd.Flags().Bool("debug", false, "")
	args := []string{"-t", os.Getenv("JIRA_TEST_TYPE"), "-s", "Test", "--raw", "--no-input"}
	if os.Getenv("JIRA_TEST_NO_BODY") != "1" {
		args = append(args, "-b", "Test")
	}
	if os.Getenv("JIRA_TEST_NO_EPIC") == "1" {
		args = append(args, "--no-epic")
	} else {
		args = append(args, "--parent", "3534")
	}
	if assignee := os.Getenv("JIRA_TEST_ASSIGNEE"); assignee != "" {
		args = append(args, "--assignee", assignee)
	}
	cmd.SetArgs(args)
	if err := cmd.Execute(); err != nil {
		os.Exit(1)
	}
	os.Exit(0)
}

func TestCreateCommand(t *testing.T) {
	for _, mode := range []string{"epic", "no epic", "no epic cancel", "no epic no input", "subtask", "cloud", "no epic stdin description", "explicit assignee", "identity failure", "missing sprint", "assignment failure"} {
		t.Run(mode, func(t *testing.T) {
			creates, assignments := 0, 0
			var mu sync.Mutex
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				mu.Lock()
				defer mu.Unlock()
				switch {
				case r.URL.Path == "/rest/api/2/myself":
					if mode == "cloud" {
						fmt.Fprint(w, `{"accountId":"self-account"}`)
						return
					}
					if mode == "identity failure" {
						http.Error(w, "unavailable", http.StatusServiceUnavailable)
						return
					}
					fmt.Fprint(w, `{"name":"tmaetzold_gcp"}`)
				case r.URL.Path == "/rest/api/2/user/assignable/search":
					if mode != "explicit assignee" || r.URL.Query().Get("username") != "alice" {
						t.Errorf("unexpected user lookup: %s", r.URL)
					}
					fmt.Fprint(w, `[{"name":"alice"}]`)
				case strings.HasPrefix(r.URL.Path, "/rest/agile/1.0/board/84/sprint"):
					if mode == "missing sprint" {
						fmt.Fprint(w, `{"isLast":true,"values":[]}`)
						return
					}
					fmt.Fprintf(w, `{"isLast":true,"values":[{"id":343,"name":"Risk-%s","state":"active"}]}`, time.Now().Format("200601"))
				case r.Method == "GET" && r.URL.Path == "/rest/api/2/search":
					fmt.Fprint(w, `{"issues":[{"key":"RD-3534"}]}`)
				case r.Method == "POST" && r.URL.Path == "/rest/api/2/issue":
					creates++
					var body struct {
						Fields map[string]interface{} `json:"fields"`
					}
					if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
						t.Error(err)
					}
					project, _ := body.Fields["project"].(map[string]interface{})
					if project["key"] != "RD" {
						t.Errorf("project = %#v", body.Fields["project"])
					}
					assignee, _ := body.Fields["assignee"].(map[string]interface{})
					wantAssignee := "tmaetzold_gcp"
					if mode == "explicit assignee" {
						wantAssignee = "alice"
					}
					if mode == "cloud" {
						wantAssignee = "self-account"
					}
					assigneeField := "name"
					if mode == "cloud" {
						assigneeField = "accountId"
					}
					if assignee[assigneeField] != wantAssignee {
						t.Errorf("assignee = %#v, want %s", assignee, wantAssignee)
					}
					if mode == "subtask" {
						parent, ok := body.Fields["parent"].(map[string]interface{})
						if !ok || parent["key"] != "RD-3534" {
							t.Errorf("parent = %#v", body.Fields)
						}
						if _, exists := body.Fields["customfield_10452"]; exists {
							t.Error("subtask must use parent, not Epic Link")
						}
					} else if mode == "no epic" {
						if _, exists := body.Fields["customfield_10452"]; exists {
							t.Error("unexpected epic")
						}
					} else if body.Fields["customfield_10452"] != "RD-3534" {
						t.Errorf("epic = %#v", body.Fields)
					}
					w.WriteHeader(http.StatusCreated)
					fmt.Fprint(w, `{"id":"1","key":"RD-TEST"}`)
				case r.Method == "POST" && r.URL.Path == "/rest/agile/1.0/sprint/343/issue":
					assignments++
					if creates != 1 {
						t.Error("sprint assignment before creation")
					}
					var body struct {
						Issues []string `json:"issues"`
					}
					if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
						t.Error(err)
					}
					if len(body.Issues) != 1 || body.Issues[0] != "RD-TEST" {
						t.Errorf("assignment = %#v", body)
					}
					if mode == "assignment failure" {
						http.Error(w, "forbidden", http.StatusForbidden)
					} else {
						w.WriteHeader(http.StatusNoContent)
					}
				default:
					t.Errorf("unexpected request %s %s", r.Method, r.URL)
					http.NotFound(w, r)
				}
			}))
			defer server.Close()
			cmd := exec.Command(os.Args[0], "-test.run=^TestCreateCommandHelper$")
			kind := "Bug"
			if mode == "subtask" {
				kind = "Sub-task"
			}
			cmd.Env = append(os.Environ(), "JIRA_CREATE_HELPER=1", "JIRA_TEST_SERVER="+server.URL, "JIRA_TEST_TYPE="+kind, "TERM=dumb")
			if mode == "cloud" {
				cmd.Env = append(cmd.Env, "JIRA_TEST_CLOUD=1")
			}
			if mode == "no epic stdin description" {
				cmd.Env = append(cmd.Env, "JIRA_TEST_NO_BODY=1")
				cmd.Stdin = strings.NewReader("description\nyes\n")
			}
			if mode == "explicit assignee" {
				cmd.Env = append(cmd.Env, "JIRA_TEST_ASSIGNEE=alice")
			}
			if strings.HasPrefix(mode, "no epic") {
				cmd.Env = append(cmd.Env, "JIRA_TEST_NO_EPIC=1")
				if mode == "no epic" {
					cmd.Stdin = strings.NewReader("yes\n")
				} else if mode == "no epic cancel" {
					cmd.Stdin = strings.NewReader("n\n")
				}
			}
			var stderr bytes.Buffer
			cmd.Stderr = &stderr
			output, err := cmd.Output()
			if strings.HasPrefix(mode, "no epic") && mode != "no epic stdin description" && !strings.Contains(stderr.String(), "Do you really want to create this ticket without an epic? [y/N]") {
				t.Fatalf("missing confirmation: %s", stderr.String())
			}
			if mode == "no epic stdin description" && !strings.Contains(string(output)+stderr.String(), "pass --body or --template explicitly") {
				t.Fatalf("missing stdin guidance: %s %s", output, stderr.String())
			}
			if mode == "no epic stdin description" || mode == "no epic cancel" || mode == "no epic no input" || mode == "identity failure" || mode == "missing sprint" {
				mu.Lock()
				defer mu.Unlock()
				if err == nil || creates != 0 || assignments != 0 {
					t.Fatalf("error=%v creates=%d assignments=%d stderr=%s", err, creates, assignments, stderr.String())
				}
				return
			}
			if mode == "assignment failure" {
				output = append(output, stderr.Bytes()...)
				if err == nil || !strings.Contains(string(output), "jira sprint add 343 RD-TEST") || !strings.Contains(string(output), "do not rerun create") {
					t.Fatalf("error=%v output=%s", err, output)
				}
			} else {
				if err != nil {
					t.Fatalf("error=%v output=%s", err, output)
				}
				var issue struct {
					Key string `json:"key"`
				}
				if err := json.Unmarshal(output, &issue); err != nil || issue.Key != "RD-TEST" {
					t.Fatalf("output=%s error=%v", output, err)
				}
			}
			mu.Lock()
			defer mu.Unlock()
			wantAssignments := 1
			if mode == "subtask" {
				wantAssignments = 0
			}
			if creates != 1 || assignments != wantAssignments {
				t.Fatalf("creates=%d assignments=%d", creates, assignments)
			}
		})
	}
}
