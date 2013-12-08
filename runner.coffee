#!/usr/local/bin/phantomjs

# Runs a Jasmine Suite from an html page
# @page is a PhantomJs page object
# @exit_func is the function to call in order to exit the script

class PhantomJasmineRunner
  constructor: (@page, @exit_func = phantom.exit) ->
    @tries = 0
    @max_tries = 10

  get_status: -> @page.evaluate(-> runner.env.currentSpec.results().passed())

  terminate: ->
    console.log 'ENDED'
    if @get_status()
      @exit_func 0
    else
      @exit_func 1

# Script Begin
if phantom.args.length == 0
  console.log "Need a url as the argument"
  phantom.exit 1

page = new WebPage()

runner = new PhantomJasmineRunner(page)

# Don't supress console output
page.onConsoleMessage = (msg) ->
  # Terminate when the reporter singals that testing is over.
  # We cannot use a callback function for this (because page.evaluate is sandboxed),
  # so we have to *observe* the website.
  if msg == "Reporter finished"
    runner.terminate()
    return

  console.log msg

address = phantom.args[0]

page.open address, (status) ->
  if status != "success"
    console.log "can't load the address!"
    phantom.exit 1
