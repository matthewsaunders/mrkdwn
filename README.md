# mrkdwn

A subset of a markdown-to-HTML converter. The gem name doesn't have any vowels, so you know it must be good!

To learn more about how mrkdwn works, read the [overview](docs/overview).

## Build and running in local irb

Follow these instructions to build and install the mrkdwn gem locally. Once installed, you can load it in a local irb session and call Mrkdwn#html to parse a markdown document string into an HTML fragment string.

1. Build the gem

```
$ gem build mrkdwn.gemspec
```

2. Install the built gem locally

```
$ gem install ./mrkdwn-0.0.0.gem
```

3. Test the gem using irb

```
$ irb
irb(main):001> require "mrkdwn"
=> true
irb(main):002> Mrkdwn.html("# Hello, mrkdwn!")
<h1>Hello, mrkdwn!</h1>
=> nil
```

## Running tests

Tests are built and run using [rspec](https://rspec.info/). There are unit test files for `Mrkdown::Parser` and `Mrkdwn::Renderer` classes, and an end-to-end test file testing the main `Mrkdwn` class.

### Prerequisites

Install the `rspec` gem.

```
$ gem install rspec
```

### Run tests

Use the following command to run all tests.

```
$ rspec
```

## Supported syntax

```
# heading 1
## heading 2
### heading 3
#### heading 4
##### heading 5
###### heading 6

// text modification
**bold**
*emphasized*
~~strikethrough~~
`inline code`


// links
[inline link](https://github.com)
```
