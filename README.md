Google-Docs-Based-username-bot
==============================

A simple Rails app that checks a Google Spreadsheet's username field to see if it contains the username from a given pull request
This is literally pulled right out of discourse's main instance. I made some changes afterward without testing, so there may be a bug or two. Feel free to message me if you find any


Installation
------------
1. Add to your gemfile:
      gem 'gdata', git: 'http://github.com/agentrock/gdata.git'
      gem 'octokit', git: 'https://github.com/pengwynn/octokit'
if you don't have octokit or gdata installed already

2. Route to the file in rails

3. Add the webhook to your project's settings by going to settings > service hooks > webhooks and adding the URL of the bot
Next, you have to add pull requests to the hook.
This can be done by sending a PATCH request over CURL (or any other HTTP inteface) to api.github.com/repos/:owner/:repo/hooks/:id (fil in your info).
The body of the PATCH must contain
    {
      "name": "web",
      "active": true,
      "add_events": [
        "pull_request"
      ],
      "config": {
        "url": "theurlfrombefore",
        "content_type": "json"
      }
    }

That's it! 
Users will have their pull requests commented on when the callback is called.
