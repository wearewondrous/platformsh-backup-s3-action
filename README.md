# platformsh-backup-s3-action

## What it does

Given a Drupal 8+ project deployed on platform.sh, this GitHub-action backups the database, public files, private files and a snapshot of the code to an
AWS bucket. Instead of using the platform sh server resources, GitHub resources are leveraged. This may be required for projects with large data dumps.
Thus, you'll be able to restore the project from the four compressed files.

With the required `aws_s3_bucket` you define the parent folder. The current _repository name_ will be used as a default folder.
Backups are folders named by the current _datetime_ (in ISO 8601 date format) containing the compressed files. An example folder structure see below:

````
<aws_s3_bucket>/
├─ <repository_name>/
│  ├─ datetime/
│  │  ├─ repository_name--branch--datetime--database.sql.gz
│  │  ├─ repository_name--branch--datetime--private-files.zip
│  │  ├─ repository_name--branch--datetime--public-files.zip
│  │  ├─ repository_name--branch--datetime--source-code.zip
│  ├─ .../
````

With the `days_to_backup` (defaults to `30`) you can limit the amount of folders in aws S3. Set it to `0` to disable this limitation and store all backups made.
Note: If no private folder is present, this file will be empty.

## Setup
Create a workflow yml file and use the example below to configure the project.
```bash
$ touch .github/workflows/sync-backups.yml
```
Add the following
```yml
name: Sync Backups
on:
  schedule:
    - cron: '0 1 * * *'
jobs:
  upload-backup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: wearewondrous/platformsh-backup-s3-action@v1
        with:
          gh_user: 'myuser' # required, GitHub user related with the Access Token
          platformsh_project: 'abcdefghijkl'  # required, Platform.sh project ID
          aws_s3_bucket: 'my-bucket'  # required, AWS S3 bucket name
        env:
          PLATFORMSH_CLI_TOKEN: ${{ secrets.PLATFORMSH_CLI_TOKEN }}
          GH_ACCESS_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_DEFAULT_REGION: ${{ secrets.AWS_DEFAULT_REGION }}
```
See [action.yml](action.yml) for more optional parameters.

Make sure to have all the required INPUT variables and add GitHub secrets set.

```yml
PLATFORMSH_CLI_TOKEN
GH_ACCESS_TOKEN
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION
```

## Credits

Made with ♥️ by [WONDROUS](www.wearewoundrous.com), Switzerland
