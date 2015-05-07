## How to bootstrap a Middleman site from this repo

1. <code>git clone git@github.com:dojo4/static_site.git</code>
2. Create a new repo under the dojo4 account on github.com
4. Switch the current directory to the new repo: <code>cd new_repo</code>
5. Remove the .git directory: <code>rm -rf .git</code>
6. Initialize the new git repo: <code>git init</code>
7. Add the github remote: <code>git remote add origin git@github.com:dojo4/new_repo_name
8. Remove vendor bundle <code>rm -rf ./vendor/bundle/ruby/</code>
9. Run <code>bundle install</code> to install the necessary gems.
10. Recrypt the sekrets config: <code>sekrets recrypt config/sekrets.yml.enc</code>
11. Create a new .sekrets.key with the new password you created above
12. Hack.

You can push to GitHub as needed from that point forward.

## How to run the middleman server locally for development

1. <code>bundle exec middleman</code>
2. point your browser at localhost:4567

## How to deploy

### Update AWS details like bucket names

<code>vi .sekrets.key</code>
<code>sekrets edit ./config/sekrets.yml.enc</code>
<code>rake deploy:staging</code> in the new folder will push the new site
to the server.

## How to browse to your site?

Point your browser to [http://static_site.site.dojo4.com](http://static_site.site.dojo4.com)

