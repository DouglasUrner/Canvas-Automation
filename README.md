# Canvas TDD

Pull student progress info from Canvas.

## Tools

### auto_score_submissions

Given an assignment on Canvas:

* Get the assignment
  - From the description field extract the URL of the underlying GitHub repository.
  - From the repository, find the auto-score.rb and load it.
* Retrieve the submissions
* For each submission
  - If url != null && (grade == null || grade_matches_current_submission == false)
  - Get the URL of the GitHub repository.
  - Run the scorer
* Post score and comment to Canvas.
* Output a table / import file for Skyward.

To do:

* Handle pagination
* "Friendly" course/section, assignment, and student references
* Break out common scoring code
* Pull URL out of a Google Doc

## Notes

* [Python 3 Unity YAML Parser](https://pypi.org/project/unityparser/)
  - Python > 3.5
  - [pip](https://pip.pypa.io/en/stable/installing/)
  - Install with Homebrew (brew install python)
* Google Docs APIs
  - [Google API Client](https://github.com/googleapis/google-api-ruby-client)
* [Canvas Pagination](https://community.canvaslms.com/thread/1500)
