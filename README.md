# Building this performance measuring output
Clone the Github repo locally.
Make sure you have JRuby 9.1.13.0 or greater. Use `rbenv` from homebrew or your OS software installer.
Make sure you install rake and bundler `gem i rake bundler`
```
cd <clone path>
gem build ./logstash-output-counter.gemspec
```
In your logstash test bed install.
```
bin/logstash-plugin install --local <clone path>/logstash-output-counter-1.0.4.gem
```
In your config
```
output {
  counter {
    warmup => 240 # allow plenty of time for JRuby and Java to JIT compile and settle down.
  }
}
```
After running your pipeline(s) for 1 - 10 minutes after the warmup, shutdown LS.
You will see a report logged as INFO in the LS logs.
e.g.
`[2018-05-25T13:13:14,865][INFO ][logstash.outputs.counter ] Benchmark report: Events per second: 40 / 0.0014431476593017578 = 27717.191475301504; microseconds per event: 36.078691482543945`
As this counter output adds a very very small performance impact, the events per second you are measuring reflects the input -> queue -> filters performance across all worker threads.
Remember to only change one variable at a time and keep records of each tweak.
In a multiple pipeline scenario, where each pipeline will have its own counter output, as all the counter outputs share a threadsafe global counter the report will be logged multiple times but the reports come from the same global counter so they are reporting on the same thing - the overall performance of running a multiple pipeline setup. Measure the perfomance of each pipeline config separately and compare.

# Logstash Plugin

This is a plugin for [Logstash](https://github.com/elasticsearch/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

Logstash provides infrastructure to automatically generate documentation for this plugin. We use the asciidoc format to write documentation so any comments in the source code will be first converted into asciidoc and then into html. All plugin documentation are placed under one [central location](http://www.elasticsearch.org/guide/en/logstash/current/).

- For formatting code or config example, you can use the asciidoc `[source,ruby]` directive
- For more asciidoc formatting tips, see the excellent reference here https://github.com/elasticsearch/docs#asciidoc-guide

## Need Help?

Need help? Try #logstash on freenode IRC or the https://discuss.elastic.co/c/logstash discussion forum.

## Developing

### 1. Plugin Developement and Testing

#### Code
- To get started, you'll need JRuby with the Bundler gem installed.

- Create a new plugin or clone and existing from the GitHub [logstash-plugins](https://github.com/logstash-plugins) organization. We also provide [example plugins](https://github.com/logstash-plugins?query=example).

- Install dependencies
```sh
bundle install
```

#### Test

- Update your dependencies

```sh
bundle install
```

- Run tests

```sh
bundle exec rspec
```

### 2. Running your unpublished Plugin in Logstash

#### 2.1 Run in a local Logstash clone

- Edit Logstash `Gemfile` and add the local plugin path, for example:
```ruby
gem "logstash-filter-awesome", :path => "/your/local/logstash-filter-awesome"
```
- Install plugin
```sh
bin/plugin install --no-verify
```
- Run Logstash with your plugin
```sh
bin/logstash -e 'filter {awesome {}}'
```
At this point any modifications to the plugin code will be applied to this local Logstash setup. After modifying the plugin, simply rerun Logstash.

#### 2.2 Run in an installed Logstash

You can use the same **2.1** method to run your plugin in an installed Logstash by editing its `Gemfile` and pointing the `:path` to your local plugin development directory or you can build the gem and install it using:

- Build your plugin gem
```sh
gem build logstash-filter-awesome.gemspec
```
- Install the plugin from the Logstash home
```sh
bin/plugin install /your/local/plugin/logstash-filter-awesome.gem
```
- Start Logstash and proceed to test the plugin

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elasticsearch/logstash/blob/master/CONTRIBUTING.md) file.
