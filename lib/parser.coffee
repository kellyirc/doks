
_ = require "lodash"
_.str = require "underscore.string"
glob = require "glob"
fs = require "fs"
ncp = require "ncp"
mkdirp = require "mkdirp"

class Expressions
  @START_COMMENT =
    js: /^\s*\/\*\*/,
    coffee: /^\s*###\*/

  @END_COMMENT =
    js: /\*\/\s*$/,
    coffee: /###\s*$/

  @LINE_HEAD_CHAR =
    js: /^\s*\*/,
    coffee: /^\s*#/

  @LINES = /\r\n|\n/

  @GLOBAL_LINES = /\r\n|\n/g

  @LINE_HEAD_CHAR =
    js: /^\s*\*/,
    coffee: /^\s*#/

  @TAG_SPLIT = /@(\w+)\s(?:{(.+)})?\s?(.+?(?=\s\(|\n|$))?\s?(?:\((.+)\))?/g

class Parser

  constructor: (options) ->

    if options.config
      options = @parseNewOptions options.config
      return if not options

    @setOptions options

  parseNewOptions: (file) ->
    try
      JSON.parse fs.readFileSync file, encoding: "UTF-8"
    catch e
      console.error "FATAL: No doks.json file found (or invalid config)."

  setOptions: (@options = {}) ->
    @options.language ?= "coffee"
    @options.glob ?= "**/*.#{@options.language}"
    @options.lib ?= "angular"
    @options.theme ?= "bootstrap"
    @options.arrayTags ?= []
    @options.defaults ?= {}
    @options.json ?= ""
    @options.outputPath ?= "doks"

  getOnlyFileName: (filePath) ->
    filePath.split("\\").pop().split("/").pop()

  getFiles: ->
    if not @options.glob
      console.error "FATAL: No file glob set."
      return []

    glob.sync @options.glob

  handleComment: (commentData) ->
    lines = commentData.comment.split Expressions.LINES
    results = []

    headRegex = Expressions.LINE_HEAD_CHAR[@options.language]

    # remove any extra characters in front of the doc string
    (lines[i] = lines[i].replace headRegex, '') for i in [0...lines.length] if lines[0] and headRegex.test lines[0]

    # strip out whitespace or * characters from both sides of the string
    (lines[i] = _.str.trim lines[i], " *") for i in [0...lines.length]

    # remove empty lines
    lines = _.compact lines

    # make the first line a @desc if it isn't one
    lines[0] = "@desc #{lines[0]}" if not _.str.startsWith lines[0], "@"

    # merge lines with their previous if the line doesn't start with @
    (lines[i-1] = "#{lines[i-1]} #{lines[i]}" if not _.str.startsWith lines[i], "@") for i in [lines.length-1...0]

    # remove all lines that don't start with @
    lines = _.filter lines, (line) -> _.str.startsWith line, "@"

    addObjectToResult = (lineArray) ->
      # lineArray[0] and lineArray[5] are empty strings. the regex works, I am not going to split hairs over this.
      [tagName, tagType, tagBasic, tagExtDesc] = [lineArray[1], lineArray[2], lineArray[3], lineArray[4]]
      tagData =
        name: tagName
        type: tagType
        basicInfo: tagBasic
        extendedInfo: tagExtDesc

      results.push tagData

    addObjectToResult line.split Expressions.TAG_SPLIT for line in lines

    # dat based default info that people probably want
    resultObj =
      lineNumber: commentData.lineNumber
      endLineNumber: commentData.endLineNumber
      filePath: commentData.file
      fileName: @getOnlyFileName commentData.file

    for arrayTag in @options.arrayTags
      typeOfArray = _.filter results, (result) -> result.name is arrayTag

      # no sense doing this if it's empty - just extra clutter at that point.
      resultObj[arrayTag] = typeOfArray if typeOfArray.length isnt 0

    nonArrayResults = _.reject results, (result) -> resultObj[result.name]

    (resultObj[result.name] = result) for result in nonArrayResults

    (resultObj[defaultKey] ?= defaultVal) for defaultKey, defaultVal of @options.defaults

    resultObj

  parse: ->
    throw new Error "You have to set a language first!" if not @options.language

    files = @getFiles()

    fileMap = {}

    _.each files, (file) =>

      # read the file and split it into lines
      fileMap[file] = []

      fileContent = fs.readFileSync file,
        encoding: "UTF-8"

      fileLines = fileContent.split Expressions.LINES

      len = fileLines.length

      # parse out comments
      for i in [0...len]
        line = fileLines[i]
        continue if not Expressions.START_COMMENT[@options.language].test line

        lineNum = i + 1
        commentLines = []

        # we have a comment, lets go until the end of the comment
        while i < len and not Expressions.END_COMMENT[@options.language].test line
          commentLines.push line
          i++
          line = fileLines[i]

        # get rid of the initial comment line
        commentLines.shift()
        commentString = commentLines.join "\n"

        # generate a comment object
        fullCommentObject = @handleComment
          lineNumber: lineNum
          endLineNumber: i+1
          file: file
          comment: commentString

        fileMap[file].push fullCommentObject

    _.flatten _.values fileMap

  getJSON: ->
    files = glob.sync @options.json

    fileMap = {}

    _.each files, (file) =>

      fileContent = fs.readFileSync file,
        encoding: "UTF-8"

      fileMap[@getOnlyFileName file] = JSON.parse fileContent

    fileMap

  copyTemplate: ->
    ncp "./themes/#{@options.theme}/#{@options.lib}", @options.outputPath, (e) ->

  write: (fileLoc = "#{@options.outputPath}/output.json") ->
    return if not @options

    startDate = Date.now()
    parsedData = @parse()
    endDate = Date.now()

    data =
      parsed: parsedData
      startTime: startDate
      endTime: endDate

    data.arbitrary = @getJSON() if @options.json

    mkdirp.sync "#{@options.outputPath}"
    fs.writeFileSync fileLoc, JSON.stringify data

    @copyTemplate()

module.exports = exports = Parser
