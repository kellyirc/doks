
_ = require "lodash"
_.str = require "underscore.string"
glob = require "glob"
fs = require "fs"
ncp = require "ncp"
mkdirp = require "mkdirp"
git = require "git-rev-sync"

###*
 * @desc This class contains all of the regular expressions used by Parser.
 *
 * @name Expressions
 * @category Class
 * @package Regex
###
class Expressions

  ###*
    * This regular expression is used to determine
    * if a line is a starting character sequence.
    * @name START_COMMENT
    * @category Comment
    * @package Regex
    * @supports {js}
    * @supports {coffee}
  ###
  @START_COMMENT =
    js: /^\s*\/\*\*/,
    coffee: /^\s*###\*/

  ###*
    * This regular expression is used to determine
    * if a line is an ending character sequence.
    * @name END_COMMENT
    * @category Comment
    * @package Regex
    * @supports {js}
    * @supports {coffee}
  ###
  @END_COMMENT =
    js: /\*\/\s*$/,
    coffee: /###\s*$/

  ###*
    * This regular expression is used to determine
    * if a character sequence precedes a comment line.
    *
    * @name LINE_HEAD_CHAR
    * @category Comment
    * @package Regex
    * @supports {js}
    * @supports {coffee}
  ###
  @LINE_HEAD_CHAR =
    js: /^\s*\*/,
    coffee: /^\s*#/

  ###*
    * This regular expression is used to split a file by lines.
    *
    * @name LINES
    * @category Line
    * @package Regex
  ###
  @LINES = /\r\n|\n/

  ###*
    * This regular expression is used to split a comment line
    * into its appropriate tokens (tagName, tagType, tagBasicInfo, tagExtendedInfo).
    *
    * @name TAG_SPLIT
    * @category Tag
    * @package Regex
  ###
  @TAG_SPLIT = /@(\w+)\s?(?:{([^\s|.]+)})?\s?(.+?(?=\s\(|\n|$))?\s?(?:\((.+)\))?/g

###*
 * @desc This class contains all of the regular expressions used by Parser.
 *
 * @name Parser
 * @category Class
 * @package TagParser
###
class Parser

  ###*
    * This function makes a new parser.
    *
    * @name constructor
    * @category Function
    * @package TagParser
    * @param {object} options
  ###
  constructor: (options) ->

    if options.config
      options = @parseNewOptions options.config
      return if not options

    @setOptions options

  ###*
    * This function parses options out of a file, formatted similarly to the options object.
    *
    * @name parseNewOptions
    * @category Function
    * @package TagParser
    * @internal
    * @param {string} file (The configuration file to parse, defaults to doks.json)
  ###
  parseNewOptions: (file) ->
    try
      JSON.parse fs.readFileSync file, encoding: "UTF-8"
    catch e
      console.error "FATAL: No doks.json file found (or invalid config): #{e.stack}"

  ###*
    * This function sets options on the Parser object.
    *
    * @name setOptions
    * @category Function
    * @package TagParser
    * @internal
    * @param {object} options (The options object to parse)
  ###
  setOptions: (@options = {}) ->

    ###*
      * This option determines what language to use.
      *
      * @name language
      * @category Option
      * @package TagParser
      * @default {string} "coffee"
    ###
    @options.language ?= "coffee"

    ###*
      * This option determines which files to glob together when generating doks.
      *
      * @name glob
      * @category Option
      * @package TagParser
      * @default {globstring} "**\*.#{options.language}"
    ###
    @options.glob ?= "**/*.#{@options.language}"

    ###*
      * This option determines which library to use when choosing a theme.
      *
      * @name lib
      * @category Option
      * @package TagParser
      * @default {string} "angular"
    ###
    @options.lib ?= "angular"

    ###*
      * This option determines which UI framework to use when choosing a theme.
      *
      * @name theme
      * @category Option
      * @package TagParser
      * @default {string} "bootstrap"
    ###
    @options.theme ?= "bootstrap"

    ###*
      * This option lets the parser know what tags happen in multiples.
      * This avoids collisions without too much guessing magic.
      *
      * @name arrayTags
      * @category Option
      * @package TagParser
      * @default {array} []
    ###
    @options.arrayTags ?= []

    ###*
      * This option lets the parser know what a tags default value should be if it isn't set.
      * Beware, this will be set on every comment object being put through the parser.
      *
      * @name defaults
      * @category Option
      * @package TagParser
      * @default {object} {}
    ###
    @options.defaults ?= {}

    ###*
      * This option tells the parser to attach arbitrary JSON to the external output.
      * Useful if you have some arbitrary JSON files you want to display in your documentation.
      *
      * @name json
      * @category Option
      * @package TagParser
      * @default {globstring} ""
    ###
    @options.json ?= ""

    ###*
      * This option determines where the resulting theme and parser output should be put.
      *
      * @name outputPath
      * @category Option
      * @package TagParser
      * @default {string} "doks"
    ###
    @options.outputPath ?= "doks"

    ###*
      * This option makes it so only the parser output is placed in the output directory.
      * If both this and themeOnly are set to true, neither will output any data.
      *
      * @name outputOnly
      * @category Option
      * @package TagParser
      * @default {boolean} false
    ###
    @options.outputOnly ?= no

    ###*
      * This option makes it so only the theme is placed in the output directory.
      * If both this and themeOnly are set to true, neither will output any data.
      *
      * @name themeOnly
      * @category Option
      * @package TagParser
      * @default {boolean} false
    ###
    @options.themeOnly ?= no

    ###*
      * This option allows for overriding template variables.
      *
      * @name templateOptions
      * @category Option
      * @package TagParser
      * @default {object} {}
    ###
    @options.templateOptions ?= {}

  ###*
    * This function turns a file path into just a file name.
    *
    * @name getOnlyFileName
    * @category Function
    * @package TagParser
    * @internal
    * @param {string} filePath (The filePath to split apart)
    * @return {string} The file name
  ###
  getOnlyFileName: (filePath) ->
    filePath.split("\\").pop().split("/").pop()

  ###*
    * This function returns a list of files based on options.glob.
    *
    * @name getFiles
    * @category Function
    * @package TagParser
    * @internal
    * @return {array} [] (If there is no glob set)
    * @return {array} The files found in the given glob
  ###
  getFiles: ->
    if not @options.glob
      console.error "FATAL: No file glob set."
      return []

    glob.sync @options.glob

  ###*
    * This function takes a comment object and turns the underlying data into a more digestible format using TAG_SPLIT.
    * It takes into account options like defaults and arrayTags to better format the resulting data.
    *
    * @name handleComment
    * @category Function
    * @package TagParser
    * @internal
    * @param {object} commentData ({lineNumber, endLineNumber, file})
    * @return {object} The new comment object
  ###
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

      console.log tagData

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

  ###*
    * This function parses a file, line by line, and gathers the appropriate data to create a basic comment object
    * (including line numbers). Additionally, if you only wanted comment data (and are using this tool programmatically),
    * you could use this instead of options.outputOnly.
    *
    * @name parse
    * @category Function
    * @package TagParser
    * @throws {Error} if a language is not set
    * @return {array} An unsorted array of comment data
  ###
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

  ###*
    * This function takes the options.json glob and gathers all of the specified JSON files into an object.
    *
    * @name getJSON
    * @category Function
    * @package TagParser
    * @return {object} A hash of each JSON file mapped to its contents, as an object
  ###
  getJSON: ->
    files = glob.sync @options.json

    fileMap = {}

    _.each files, (file) =>

      fileContent = fs.readFileSync file,
        encoding: "UTF-8"

      fileMap[@getOnlyFileName file] = JSON.parse fileContent

    fileMap

  ###*
    * This function copies the specified template to the output directory specified.
    * It also handles merging any template options.
    *
    * @name copyTemplate
    * @category Function
    * @package TagParser
  ###
  copyTemplate: ->
    ncp "./themes/#{@options.theme}-#{@options.lib}", @options.outputPath, =>
      fileContent = JSON.parse fs.readFileSync "#{@options.outputPath}/config.json",
        encoding: "UTF-8"

      fileContent.options = _.merge fileContent.options, @options.templateOptions

      fs.writeFileSync "#{@options.outputPath}/config.json", JSON.stringify fileContent, null, 4

  ###*
    * This function aggregates all possible data (parse times, git metadata, JSON, parsed comment data, theme-related options)
    * and handles all of the writing. All data is written to outputPath/output.json.
    *
    * @name write
    * @category Function
    * @package TagParser
  ###
  write: (fileLoc = "#{@options.outputPath}/output.json") ->
    return if not @options

    startDate = Date.now()
    parsedData = @parse()
    endDate = Date.now()

    data =
      parsed: parsedData
      startTime: startDate
      endTime: endDate
      git:
        short: git.short()
        long: git.long()
        branch: git.branch()
        tag: git.tag()

    data.arbitrary = @getJSON() if @options.json

    mkdirp.sync "#{@options.outputPath}"

    fs.writeFileSync fileLoc, JSON.stringify data, null, 4 if not @options.themeOnly

    @copyTemplate() if not @options.outputOnly

module.exports = exports = Parser
