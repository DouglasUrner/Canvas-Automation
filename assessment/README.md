# Scoring Methods

## Architecture

These files are the boilerplate for automated assignment scoring. In production they are deployed in the `assessment` folder of the GitHub repository for the assignment. That repository is found by looking at the URL in the assignment's `description` field on Canvas (which is assumed to be a GitHub Pages site).

* **auto_score.rb** *repository_URL*  
The scoring driver, it is called with the URL of the student repository to be assessed. This code can be customized to the repository being scored, but it does a passable job using `config.yml` to tune its behavior.

* **config_generator.rb** *meta-config.yml master-repo > config.yml*   
Reads `meta-config.yml` and the master repository to generate the configuration file to drive `auto-score.rb`.

The *master-repo* is a Git repository of the project exemplar, it is used to get tuning values that are used to fill in `config.yml`. A lot of the basic process could be driven by walking the project branches - for example, the file count, new files added, changes to the scene file, etc., could all probably be calculated and set in `config.yml` and even used to stub methods for checking the scripts and scene file for example.
