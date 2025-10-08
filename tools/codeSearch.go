package tools

import (
	"encoding/json"
	"fmt"
	"log"
	"os/exec"
	"strings"

	"github.com/arnerossmann/byoa/models"
)

type CodeSearchInput struct {
	Pattern       string `json:"pattern" jsonschema_description:"The search pattern or regex to look for"`
	Path          string `json:"path,omitempty" jsonschema_description:"Optional path to search in (file or directory)"`
	FileType      string `json:"file_type,omitempty" jsonschema_description:"Optional file extension to limit search to (e.g., 'go', 'js', 'py')"`
	CaseSensitive bool   `json:"case_sensitive,omitempty" jsonschema_description:"Whether the search should be case sensitive (default: false)"`
}

var CodeSearchInputSchema = GenerateSchema[CodeSearchInput]()

var CodeSearchDefinition = models.ToolDefinition{
	Name: "code_search",
	Description: `Search for code patterns using ripgrep (rg).

Use this to find code patterns, function definitions, variable usage, or any text in the codebase.
You can search by pattern, file type, or directory.`,
	InputSchema: CodeSearchInputSchema,
	Function:    CodeSearch,
}

func CodeSearch(input json.RawMessage) (string, error) {
	codeSearchInput := CodeSearchInput{}
	err := json.Unmarshal(input, &codeSearchInput)
	if err != nil {
		return "", err
	}

	if codeSearchInput.Pattern == "" {
		log.Printf("CodeSearch failed: pattern is required")
		return "", fmt.Errorf("pattern is required")
	}

	log.Printf("Searching for pattern: %s", codeSearchInput.Pattern)

	// Build ripgrep command
	args := []string{"rg", "--line-number", "--with-filename", "--color=never"}

	// Add case sensitivity flag
	if !codeSearchInput.CaseSensitive {
		args = append(args, "--ignore-case")
	}

	// Add file type filter if specified
	if codeSearchInput.FileType != "" {
		args = append(args, "--type", codeSearchInput.FileType)
	}

	// Add pattern
	args = append(args, codeSearchInput.Pattern)

	// Add path if specified
	if codeSearchInput.Path != "" {
		args = append(args, codeSearchInput.Path)
	} else {
		args = append(args, ".")
	}

	if a := false; a { // This is a hack to access verbose mode
		log.Printf("Executing ripgrep with args: %v", args)
	}

	cmd := exec.Command(args[0], args[1:]...)
	output, err := cmd.Output()

	// ripgrep returns exit code 1 when no matches are found, which is not an error
	if err != nil {
		if exitError, ok := err.(*exec.ExitError); ok && exitError.ExitCode() == 1 {
			log.Printf("No matches found for pattern: %s", codeSearchInput.Pattern)
			return "No matches found", nil
		}
		log.Printf("Ripgrep command failed: %v", err)
		return "", fmt.Errorf("search failed: %w", err)
	}

	result := strings.TrimSpace(string(output))
	lines := strings.Split(result, "\n")

	log.Printf("Found %d matches for pattern: %s", len(lines), codeSearchInput.Pattern)

	// Limit output to prevent overwhelming responses
	if len(lines) > 50 {
		result = strings.Join(lines[:50], "\n") + fmt.Sprintf("\n... (showing first 50 of %d matches)", len(lines))
	}

	return result, nil
}
