package root

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

func TestRiskProjectHelper(t *testing.T) {
	if os.Getenv("JIRA_PROJECT_HELPER") != "1" {
		return
	}
	cmd := NewCmdRoot()
	args := []string{"--config", os.Getenv("JIRA_TEST_CONFIG"), "issue", "create", "-t", "Bug", "-s", "Test", "-b", "Test", "--parent", "123", "--raw", "--no-input"}
	if project := os.Getenv("JIRA_TEST_PROJECT"); project != "" {
		args = append(args, "--project", project)
	}
	cmd.SetArgs(args)
	if err := cmd.Execute(); err != nil {
		os.Exit(1)
	}
	os.Exit(0)
}

func TestRiskProjectDefaults(t *testing.T) {
	for _, tc := range []struct{ name, configured, flag, want string }{
		{"missing", "", "", "RD"}, {"configured", "OTHER", "", "OTHER"}, {"override", "OTHER", "OVERRIDE", "OVERRIDE"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			creates := 0
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				switch r.URL.Path {
				case "/rest/api/2/myself":
					fmt.Fprint(w, `{"name":"tmaetzold_gcp"}`)
				case "/rest/agile/1.0/board/84/sprint":
					fmt.Fprintf(w, `{"isLast":true,"values":[{"id":343,"name":"Risk-%s","state":"active"}]}`, time.Now().Format("200601"))
				case "/rest/api/2/issue":
					creates++
					var body struct {
						Fields struct {
							Project struct {
								Key string `json:"key"`
							} `json:"project"`
						} `json:"fields"`
					}
					if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
						t.Error(err)
					}
					if body.Fields.Project.Key != tc.want {
						t.Errorf("project=%s, want %s", body.Fields.Project.Key, tc.want)
					}
					w.WriteHeader(http.StatusCreated)
					fmt.Fprint(w, `{"key":"RD-TEST"}`)
				case "/rest/agile/1.0/sprint/343/issue":
					w.WriteHeader(http.StatusNoContent)
				default:
					t.Errorf("unexpected request %s", r.URL)
					http.NotFound(w, r)
				}
			}))
			defer server.Close()
			config := filepath.Join(t.TempDir(), "jira.yml")
			text := fmt.Sprintf("server: %s\ninstallation: Local\nlogin: tmaetzold_gcp\nproject:\n  type: classic\n", server.URL)
			if tc.configured != "" {
				text += "  key: " + tc.configured + "\n"
			}
			text += "epic:\n  link: customfield_10452\nissue:\n  types:\n    - id: '1'\n      name: Bug\n      subtask: false\n"
			if err := os.WriteFile(config, []byte(text), 0600); err != nil {
				t.Fatal(err)
			}
			cmd := exec.Command(os.Args[0], "-test.run=^TestRiskProjectHelper$")
			// Do not inherit project environment overrides from the developer's shell.
			for _, env := range os.Environ() {
				if !strings.HasPrefix(env, "JIRA_") {
					cmd.Env = append(cmd.Env, env)
				}
			}
			cmd.Env = append(cmd.Env, "JIRA_PROJECT_HELPER=1", "JIRA_TEST_CONFIG="+config, "JIRA_TEST_PROJECT="+tc.flag, "JIRA_API_TOKEN=mock-only", "TERM=dumb")
			if output, err := cmd.CombinedOutput(); err != nil {
				t.Fatalf("error=%v output=%s", err, output)
			}
			if creates != 1 {
				t.Fatalf("creates=%d", creates)
			}
		})
	}
}
