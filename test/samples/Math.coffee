###*
 * @desc This class does math-like things.
 *
 * @class MathExample
 * @type Class
###

###*
 * @desc This is just a dummy class.
 *
 * @class TestClass
 * @type Class
###

###*
 * @desc This is a dummy function.
 *
 * @name dummy
 * @type Function
 * @category Simple
 * @class TestClass
 * @param {Number} a (The first number)
 * @param {Number} b (The second number)
 * @return {Number} a+b (The result of a+b)
###

class MathExample

  ###*
   * @desc Adds two numbers together. Here, we specify the type of the parameters. (tesT)
   *
   * @name add
   * @type Function
   * @category Simple
   * @class MathExample
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
  # * @desc Subtract two numbers.
  # * @name sub
  # * @category Simple
  # * @class MathExample
  # * @param a (The first number)
  # * @param b (The second number)
  # * @return a+b
  ###
  sub: (a, b) -> a-b

  ###*
  #* Divide two numbers.
  #* This is a multiline message spanning two lines.
  #*
  #* @name div
  #* @category Complex
  #* @class MathExample
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
   * @class MathExample
   * @category Complex
   * @param a (The first number)
   * @param b (The second number)
   * @return a+b
  ###
  mul: (a, b) -> a*b

  fun: (a = (->), b) -> a b

# Editor Note: The general syntax for a tag is:
# @[tagName] [{tagType}]? [tagBasic] [- tagExtendedDescription]?