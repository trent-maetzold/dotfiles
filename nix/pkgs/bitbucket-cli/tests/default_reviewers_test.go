package pr

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestRequiredDefaultReviewers(t *testing.T) {
	for _, kind := range []string{"dc", "cloud"} {
		for _, flag := range []string{"", "--with-default-reviewers=false"} {
			for _, fail := range []bool{false, true} {
				t.Run(kind+"/"+flag+"/"+map[bool]string{false: "success", true: "lookup failure"}[fail], func(t *testing.T) {
					creates, lookups := 0, 0
					var body map[string]any
					server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
						w.Header().Set("Content-Type", "application/json")
						switch {
						case r.URL.Path == "/user":
							json.NewEncoder(w).Encode(map[string]any{"username": "me", "uuid": "{me}"})
						case strings.HasSuffix(r.URL.Path, "/repos/upstream"):
							json.NewEncoder(w).Encode(map[string]any{"id": 202, "slug": "upstream"})
						case strings.Contains(r.URL.Path, "default-reviewers"):
							lookups++
							if fail {
								http.Error(w, "forbidden", http.StatusForbidden)
								return
							}
							if kind == "dc" {
								if r.URL.Query().Get("sourceRefId") != "feature" || r.URL.Query().Get("targetRefId") != "main" {
									t.Errorf("wrong branch query: %s", r.URL)
								}
								json.NewEncoder(w).Encode([]map[string]any{{"name": "alice"}, {"name": "bob"}})
							} else {
								json.NewEncoder(w).Encode(map[string]any{"values": []map[string]any{
									{"user": map[string]any{"username": "alice", "uuid": "{alice}"}},
									{"user": map[string]any{"username": "bob", "uuid": "{bob}"}},
									{"user": map[string]any{"username": "me", "uuid": "{me}"}},
								}})
							}
						case r.Method == "POST" && (strings.HasSuffix(r.URL.Path, "/pull-requests") || strings.HasSuffix(r.URL.Path, "/pullrequests")):
							creates++
							if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
								t.Error(err)
							}
							json.NewEncoder(w).Encode(map[string]any{"id": 17, "title": "Test"})
						default:
							t.Errorf("unexpected request: %s %s", r.Method, r.URL)
							http.NotFound(w, r)
						}
					}))
					defer server.Close()
					cmd := newCreateCmd(newForkCreateFactory(server.URL, kind))
					cmd.SilenceErrors = true
					cmd.SilenceUsage = true
					cmd.SetContext(context.Background())
					args := []string{"--title", "Test", "--source", "feature", "--target", "main", "--reviewer", "alice", "--reviewer", "charlie"}
					if flag != "" {
						args = append(args, flag)
					}
					cmd.SetArgs(args)
					err := cmd.Execute()
					if fail {
						if err == nil || creates != 0 || lookups == 0 {
							t.Fatalf("err=%v creates=%d lookups=%d", err, creates, lookups)
						}
						return
					}
					if err != nil || creates != 1 || lookups == 0 {
						t.Fatalf("err=%v creates=%d lookups=%d", err, creates, lookups)
					}
					reviewers, _ := body["reviewers"].([]any)
					got := map[string]int{}
					for _, value := range reviewers {
						user := value.(map[string]any)
						if kind == "dc" {
							user = user["user"].(map[string]any)
							got[user["name"].(string)]++
						} else {
							got[user["username"].(string)]++
						}
					}
					if len(reviewers) != 3 || got["alice"] != 1 || got["bob"] != 1 || got["charlie"] != 1 {
						t.Fatalf("reviewers=%#v", reviewers)
					}
				})
			}
		}
	}
}
