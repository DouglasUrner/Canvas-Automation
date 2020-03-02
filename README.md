# Canvas Automation

Pull student progress info from Canvas.

## Tools

### auto_score_submissions

* Git / GitHub workflow
* Coding standards
* Unity skills & knowledge
  - Parse & examine the scene file
  - Tests?
* Code development (algorithms & structures)
* C# skills & knowledge

#### Process

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
  - Current assignments have components that can't be machine scored. Hand scoring or machine scoring will set the graded attribute. Maybe this could be worked around by using the negative of my UID for machine scoring and hand scoring before machine scoring. It might make more sense to split the machine scored assignments from the hand scored ones. How does an assignment look when it has been machine scored (scoring ID in negative)? A further step would be to investigate tools for parsing a Google Doc to see if it is possible to pull data out of the table and display it as the automatic scoring is happening so that there is only one scoring event.
* Make it easier to share and edit comments - store them in a shared YAML file?
* Output a table / import file for Skyward.

To do:

* [-] Handle pagination
* [-] "Friendly" course/section, assignment, and student references
* [ ] Break out common scoring code
* [x] Pull URL out of a Google Doc

## Notes

* Canvas API
  - [Live API Docs](https://canvas.instructure.com/doc/api/live)

* [Python 3 Unity YAML Parser](https://pypi.org/project/unityparser/)
  - Python > 3.5
  - [pip](https://pip.pypa.io/en/stable/installing/)
  - Install with Homebrew (brew install python)
* Google Docs APIs
  - [Google Docs APIv1](https://developers.google.com/docs/api/)
  - [Google API Client for Ruby](https://github.com/googleapis/google-api-ruby-client)
  - [Google Developers](https://developers.google.com/)
* [Canvas Pagination](https://community.canvaslms.com/thread/1500)
* YAML
  - [Psych](https://ruby-doc.org/stdlib-2.1.0/libdoc/psych/rdoc/Psych.html#method-c-load_stream)
  - [YAML Cookbook for Ruby](https://yaml.org/YAML_for_ruby.html)
  - [Robot Has No Heart: YAML Tutorial](https://rhnh.net/2011/01/31/yaml-tutorial/)
  - [How do I break a string over multiple lines?](https://stackoverflow.com/questions/3790454/how-do-i-break-a-string-over-multiple-lines)
* PDF Disassembly
  - [Yomu](https://github.com/yomurb/yomu) - appears to be abandoned
  - [Henkai]() - fork of Yomu that is being maintained
  - [yob/df-reader](https://github.com/yob/pdf-reader) - doesn't do HTML, but also doesn't use Apache Tiki and seems faster
  - [Nokogiri]()
  - [Poppler](https://en.wikipedia.org/wiki/Poppler_(software)) - another PDF reader, claims to support attributes which might provide access to repo URLs.
  - [Indexing PDF For Searching Using Tika, Nokogiri, and Algolia](https://stories.algolia.com/indexing-pdf-or-other-file-contents-for-searching-b2499c23568f)
