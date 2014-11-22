###*
 * @desc This class does math-like things.
 *
 * @package Math
 * @name MathExample
 * @category Class
###

###*
  * This is a category full of complex things.
  * @name Complex
  * @category Complex
  * @package Math
###

###*
 * @desc This is just a dummy class.
 *
 * @package Test
 * @name TestClass
 * @category Class
###

###*
 * @desc This is a dummy function.
 *
 * @name dummy
 * @type Function
 * @category Simple
 * @package Test
 * @param {Number} a (The first number)
 * @param {Number} b (The second number)
 * @return {Number} a+b (The result of a+b)
###

class MathExample

  ###*
  # * @desc Subtract two numbers.
  # * @name sub
  # * @category Simple
  # * @package Math
  # * @param a (The first number)
  # * @param b (The second number)
  # * @return a+b
  ###
  sub: (a, b) -> a-b

  ###*
   * @desc Adds two numbers together. Here, we specify the type of the parameters. (tesT)
   *
   * @name add
   * @type Function
   * @category Simple
   * @package Math
   * @param {Number} a (The first number)
   * @param {Number} b (The second number)
   * @return {Number} a+b (The result of a+b)
  ###

  # Editor note: Not sure if this can be done automatically, users will probably have to specify what tags exist and their types
  # Because I don't know if it's easy to reliably guess what should be an array and what shouldn't, and that behaviour should be consistent
  # Of course, we can still pick up unspecified tags, but there's no guarantee that it will be handled correctly
  # Perhaps users will specify that in a config file.
  add: (a, b) -> a+b

  ###*
  #* Divide two numbers.
  #* This is a multiline message spanning two lines.
  #*
  #* @name div
  #* @category Complex
  #* @package Math
  #* @param a (The first number)
  #* @param b (The second number)
  #* @return a+b
  ###
  div: (a, b) -> a/b

  ###*
   * @desc Multiply two numbers.
   * This is a multiline message spanning
   * 3 lines.
   *
   * @name mul
   * @package Math
   * @category Complex
   * @param a (The first number)
   * @param b (The second number)
   * @return a+b
  ###
  mul: (a, b) -> a*b

  `/**
    * @param test
    * @goob lol
    */`
  #`/**
  # * @param test2
  # * @goob lol2
  # */`
  fun: (a = (->), b) -> a b

# Editor Note: The general syntax for a tag is:
# @[tagName] [{tagType}]? [tagBasic] [- tagExtendedDescription]?