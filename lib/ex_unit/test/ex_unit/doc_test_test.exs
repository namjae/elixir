Code.require_file("../test_helper.exs", __DIR__)

defmodule ExUnit.BeamHelpers do
  # Beam files compiled on demand
  path = Path.expand("../../tmp/beams", __DIR__)
  File.rm_rf!(path)
  File.mkdir_p!(path)
  Code.prepend_path(path)

  def write_beam({:module, name, bin, _} = res) do
    beam_path = Path.join(unquote(path), Atom.to_string(name) <> ".beam")
    File.write!(beam_path, bin)
    res
  end
end

defmodule ExUnit.DocTestTest.GoodModule do
  @doc """
  iex> one()
  1
  iex> one() + 1
  2
  """
  def one, do: 1

  @doc """
  iex> List.flatten([])
  """
  def only_call, do: :ok

  @doc ~S"""
  iex> ~S(f#{o}o)
  "f\#{o}o"
  """
  def test_sigil, do: :ok

  @doc "    iex>1 + 2\n    3"
  def no_trailing_new_line, do: :ok

  @doc """
  iex> a = 1
  iex> b = a + 2
  3
  iex> a + b
  4
  """
  def single_context, do: :ok

  @doc """
  iex> raise "message"
  ** (RuntimeError) message

  iex> raise "message"
  ** (RuntimeError) message
  """
  def two_exceptions, do: :ok

  @doc """
  iex> raise "message"
  ** (RuntimeError) message
  """
  def exception_test, do: :ok

  @doc ~S"""
  iex> raise "foo\nbar"
  ** (RuntimeError) foo
  bar
  """
  def multiline_exception_test, do: :ok
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest.MultipleExceptions do
  @doc """
  iex> 1 + ""
  ** (ArithmeticError) bad argument in arithmetic expression
  iex> 2 + ""
  ** (ArithmeticError) bad argument in arithmetic expression
  """
  def two_exceptions, do: :ok
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest.SomewhatGoodModuleWithOnly do
  @doc """
  iex> one()
  1
  iex> one() + 1
  2
  """
  def one, do: 1

  @doc """
  iex> two()
  2
  iex> two() + 1
  100
  """
  def two, do: 2
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest.SomewhatGoodModuleWithExcept do
  @moduledoc """
  iex> 1 + 1
  1
  """

  @doc """
  iex> one()
  1
  iex> one() + 1
  2
  """
  def one, do: 1

  @doc """
  iex> two()
  2
  iex> two() + 1
  100
  """
  def two, do: 2
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest.NoImport do
  @doc """
  iex> ExUnit.DocTestTest.NoImport.max(1, 2)
  {:ok, 2}

  iex> max(1, 2)
  2
  """
  def max(a, b), do: {:ok, Kernel.max(a, b)}
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest.Invalid do
  def starting_line, do: __ENV__.line + 2

  @moduledoc """

      iex> 1 + * 1
      1

      iex> 1 + hd(List.flatten([1]))
      3

      iex> a = "This is an egregiously long text string."
      iex> b = ~r{an egregiously long}
      iex> c = "a slightly shorter"
      iex> String.replace(a, b, c)
      "This is a much shorter text string."

      iex> :oops
      #Inspect<[]>

      iex> Hello.world()
      :world

      iex> raise "oops"
      ** (WhatIsThis) oops

      iex> raise "oops"
      ** (RuntimeError) hello

  """

  @doc """
      iex> 1 + * 1
      1
  """
  def a(), do: :ok

  @doc """
      iex> 1 + * 1
      1
  """
  defmacro b(), do: :ok

  @doc """
    ```
    iex> 1 + 2
    3
  ```
  """
  def indented_not_enough, do: :ok

  @doc ~S'''
  ```
  iex> 1 + 2
  3
    ```
  '''
  def indented_too_much, do: :ok

  @doc """
      ```
  iex> 1 + 2
  3
      ```
  """
  def dedented_past_fence, do: :ok

  @doc """
  iex> String.valid?("invalid utf8 \xFF")
  false
  """
  def invalid_utf8, do: :ok

  @doc """
      iex> {:ok, :oops}
      {:ok, #Inspect<[]>}
  """
  def misplaced_opaque_type, do: :ok

  @typedoc """
      iex> 1 + * 1
      1
  """
  @type t :: any()

  @doc """
      # This will fail to inspect
      iex> ExUnit.DocTestTest.Haiku.new(:this, :is, {:not, :a, :haiku})
      #Haiku<:this_wont_be_asserted>
  """
  def raising_inspect, do: :ok
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest.IndentationHeredocs do
  @doc ~S'''
  Receives a test and formats its failure.

  ## Examples

      iex> "  1\n  2\n"
      """
        1
        2
      """

  '''
  def heredocs, do: :ok
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest.IndentationMismatchedPrompt do
  @doc ~S'''
    iex> foo = 1
     iex> bar = 2
    iex> foo + bar
    3
  '''
  def mismatched, do: :ok
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest.IndentationTooMuch do
  @doc ~S'''
    iex> 1 + 2
      3
  '''
  def too_much, do: :ok
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest.IndentationNotEnough do
  @doc ~S'''
      iex> 1 + 2
    3
  '''
  def test_fun, do: :ok
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest.FencedHeredocs do
  @doc ~S'''
  Receives a test and formats its failure.

  ## Examples

  ```
  iex> 1 + 2
  3
  ```

      ```
      iex> 1 + 2
      3
      ```

  ```
      iex> 1 + 2
      3
  ```
  '''
  def heredocs, do: :ok

  @doc ~S'''
  ```
  iex> 1 + 2
  3
  '''
  def incomplete, do: :ok
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest.FenceIncomplete do
  @doc ~S'''
  ```
  iex> 1 + 2
  3
  '''
  def test_fun, do: :ok
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest.Numbered do
  @doc """
  iex(1)> 1 +
  ...(1)> 2
  3
  """
  def test_fun(), do: :ok
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest.Host do
  @doc """
      iex(foo@bar)1> 1 +
      ...(foo@bar)1> 2
      3
  """
  def test_fun(), do: :ok
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest.Haiku do
  @moduledoc """
  This module describes the ancient Japanese poem form known as Haiku.

  The Inspect protocol has been overridden for `%Haiku{}`
  so that Haikus are shown in a pretty-printed fashion.

  This module is part of the DocTest test suite,
  to ensure that DocTest can handle opaque inspect types
  which contain unicode and possibly consist of multiple lines.
  """

  defstruct [:first_phrase, :second_phrase, :third_phrase, :author]

  @doc """
  Creates a new Haiku.

  Optionally pass in the `author` as fourth argument.

  ## Examples:

      # Simple Haiku, inspect output consists of multiple lines.
      iex> ExUnit.DocTestTest.Haiku.new("Haikus are easy", "But sometimes they don't make sense", "Refrigerator")
      #Haiku<
        Haikus are easy
        But sometimes they don't make sense
        Refrigerator
      >

      # Haiku with Unicode characters (Japanese Kanji, em-dash).
      iex> ExUnit.DocTestTest.Haiku.new("古池や", "蛙飛びこむ", "水の音", "Matsuo Basho")
      #Haiku<
        古池や
        蛙飛びこむ
        水の音
        -- Matsuo Basho
      >

  """
  def new(first, second, third, author \\ "") do
    %__MODULE__{
      first_phrase: first,
      second_phrase: second,
      third_phrase: third,
      author: author
    }
  end

  @doc """
       iex> ExUnit.DocTestTest.Haiku.new("古池や", "蛙飛びこむ", "水の音", "Matsuo Basho")
       #Haiku<
         古池や
         蛙飛びこむ
         水の音
         -- Matsuo Basho
       >
       """
       |> String.replace("\n", "\r\n")
  def crlf_test, do: :ok

  defimpl Inspect do
    def inspect(haiku, _opts) do
      author = if haiku.author == "", do: "", else: "\n  -- #{haiku.author}"

      """
      #Haiku<
        #{haiku.first_phrase}
        #{haiku.second_phrase}
        #{haiku.third_phrase}#{author}
      >
      """
      |> String.trim_trailing("\n")
    end
  end
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest.PatternMatching do
  def starting_line, do: __ENV__.line + 2

  @moduledoc """
  The doctests below test pattern matching failures.

      iex> {1, 2}={1, 3}

      iex> tuple = {1, 3}
      iex> {1, 2} = tuple

      iex> "Hello, world" = "Hello world"

      iex> "Hello, " <> _ = "Hello world"

      iex> [:a | _] = [:b, :a]

      iex> atom = :a
      iex> [^atom | _] = [:b, :a]

      iex> %{b: _, d: :e} = %{a: :c, d: :e}

      iex> %{year: 2001, day: 1} = ~D[2000-01-01]

      iex> adder = fn int -> int + 1 end
      iex> num =
      ...>   adder.(0)
      iex> {^num, _, _} =
      ...> # Comments can be here as well
      ...>
      ...>   {adder.(0), adder.(1), :three}

      # false assertions do not accidentally raise
      iex> false = (List.flatten([]) != [])
  """
  def doctest(), do: :ok
end
|> ExUnit.BeamHelpers.write_beam()

defmodule ExUnit.DocTestTest do
  use ExUnit.Case

  # This is intentional. The doctests in DocTest's docs
  # fail for demonstration purposes.
  # doctest ExUnit.DocTest

  doctest ExUnit.DocTestTest.GoodModule, import: true

  doctest ExUnit.DocTestTest.SomewhatGoodModuleWithOnly,
    only: [:moduledoc, one: 0],
    import: true

  doctest ExUnit.DocTestTest.SomewhatGoodModuleWithExcept,
    except: [:moduledoc, two: 0],
    import: true

  doctest ExUnit.DocTestTest.NoImport
  doctest ExUnit.DocTestTest.IndentationHeredocs
  doctest ExUnit.DocTestTest.FencedHeredocs
  doctest ExUnit.DocTestTest.Haiku

  import ExUnit.CaptureIO

  test "multiple functions filtered with :only" do
    defmodule MultipleOnly do
      use ExUnit.Case
      doctest ExUnit.DocTestTest.SomewhatGoodModuleWithOnly, only: [one: 0, two: 0], import: true
    end

    assert capture_io(fn -> ExUnit.run() end) =~ "2 doctests, 1 failure"
  end

  test "empty :only" do
    defmodule EmptyOnly do
      use ExUnit.Case
      doctest ExUnit.DocTestTest.SomewhatGoodModuleWithOnly, only: [], import: true
    end

    output = capture_io(fn -> ExUnit.run() end)

    assert output =~ "0 failures"
    refute output =~ "doctest"
  end

  test "allows users to tag doctests with configuration options" do
    defmodule TaggedTests do
      use ExUnit.Case
      doctest ExUnit.DocTestTest.SomewhatGoodModuleWithOnly, tags: [skip: true], import: true
    end

    output = capture_io(fn -> ExUnit.run() end)

    assert output =~ "0 failures"
    assert output =~ "2 skipped"
  end

  test "doctest failures" do
    # When adding or removing lines above this line, the tests below will
    # fail because we are explicitly asserting some doctest lines from
    # ActuallyCompiled in the format of "test/ex_unit/doc_test_test.exs:<LINE>".
    defmodule ActuallyCompiled do
      use ExUnit.Case
      doctest ExUnit.DocTestTest.Invalid
    end

    doctest_line = __ENV__.line - 3
    starting_line = ExUnit.DocTestTest.Invalid.starting_line() + 2

    ExUnit.configure(seed: 0, colors: [enabled: false])
    output = capture_io(fn -> ExUnit.run() end)

    assert output =~ """
             1) doctest module ExUnit.DocTestTest.Invalid (1) (ExUnit.DocTestTest.ActuallyCompiled)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                Doctest did not compile, got: (SyntaxError) test/ex_unit/doc_test_test.exs:#{starting_line}:6: syntax error before: '*'
                 #{line_placeholder(starting_line)} |
                 #{starting_line} |  1 + * 1
                 #{line_placeholder(starting_line)} |      ^
                doctest:
                  iex> 1 + * 1
                  1
                stacktrace:
                  test/ex_unit/doc_test_test.exs:#{starting_line}: ExUnit.DocTestTest.Invalid (module)
           """

    assert output =~ """
             2) doctest module ExUnit.DocTestTest.Invalid (2) (ExUnit.DocTestTest.ActuallyCompiled)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                Doctest failed
                doctest:
                  iex> 1 + hd(List.flatten([1]))
                  3
                code:  1 + hd(List.flatten([1])) === 3
                left:  2
                right: 3
                stacktrace:
                  test/ex_unit/doc_test_test.exs:#{starting_line + 3}: ExUnit.DocTestTest.Invalid (module)
           """

    assert output =~ """
             3) doctest module ExUnit.DocTestTest.Invalid (3) (ExUnit.DocTestTest.ActuallyCompiled)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                Doctest failed
                doctest:
                  iex> a = "This is an egregiously long text string."
                  iex> b = ~r{an egregiously long}
                  iex> c = "a slightly shorter"
                  iex> String.replace(a, b, c)
                  "This is a much shorter text string."
                code:  String.replace(a, b, c) === "This is a much shorter text string."
                left:  "This is a slightly shorter text string."
                right: "This is a much shorter text string."
                stacktrace:
                  test/ex_unit/doc_test_test.exs:#{starting_line + 6}: ExUnit.DocTestTest.Invalid (module)
           """

    assert output =~ """
             4) doctest module ExUnit.DocTestTest.Invalid (4) (ExUnit.DocTestTest.ActuallyCompiled)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                Doctest failed
                doctest:
                  iex> :oops
                  "#Inspect<[]>"
                code:  inspect(:oops) === "#Inspect<[]>"
                left:  ":oops"
                right: "#Inspect<[]>"
                stacktrace:
                  test/ex_unit/doc_test_test.exs:#{starting_line + 12}: ExUnit.DocTestTest.Invalid (module)
           """

    assert output =~ """
             5) doctest module ExUnit.DocTestTest.Invalid (5) (ExUnit.DocTestTest.ActuallyCompiled)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                ** (UndefinedFunctionError) function Hello.world/0 is undefined (module Hello is not available)
                stacktrace:
                  Hello.world()
                  (for doctest at) test/ex_unit/doc_test_test.exs:#{starting_line + 15}: (test)
           """

    assert output =~ """
             6) doctest module ExUnit.DocTestTest.Invalid (6) (ExUnit.DocTestTest.ActuallyCompiled)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                Doctest failed: expected exception WhatIsThis but got RuntimeError with message "oops"
                doctest:
                  iex> raise "oops"
                  ** (WhatIsThis) "oops"
                stacktrace:
                  test/ex_unit/doc_test_test.exs:#{starting_line + 18}: ExUnit.DocTestTest.Invalid (module)
           """

    assert output =~ """
             7) doctest module ExUnit.DocTestTest.Invalid (7) (ExUnit.DocTestTest.ActuallyCompiled)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                Doctest failed: wrong message for RuntimeError
                expected:
                  "hello"
                actual:
                  "oops"
                doctest:
                  iex> raise "oops"
                  ** (RuntimeError) "hello"
                stacktrace:
                  test/ex_unit/doc_test_test.exs:#{starting_line + 21}: ExUnit.DocTestTest.Invalid (module)
           """

    assert output =~ """
             8) doctest ExUnit.DocTestTest.Invalid.a/0 (8) (ExUnit.DocTestTest.ActuallyCompiled)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                Doctest did not compile, got: (SyntaxError) test/ex_unit/doc_test_test.exs:#{starting_line + 27}:6: syntax error before: '*'
                 #{line_placeholder(starting_line + 27)} |
                 #{starting_line + 27} |  1 + * 1
                 #{line_placeholder(starting_line + 27)} |      ^
                doctest:
                  iex> 1 + * 1
                  1
                stacktrace:
                  test/ex_unit/doc_test_test.exs:#{starting_line + 27}: ExUnit.DocTestTest.Invalid (module)
           """

    assert output =~ """
             9) doctest ExUnit.DocTestTest.Invalid.dedented_past_fence/0 (9) (ExUnit.DocTestTest.ActuallyCompiled)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                Doctest did not compile, got: (SyntaxError) test/ex_unit/doc_test_test.exs:#{starting_line + 57}:5: unexpected token: "`" (column 5, code point U+0060)
                 #{line_placeholder(starting_line + 57)} |
                 #{starting_line + 57} |     ```
                 #{line_placeholder(starting_line + 57)} |     ^
                doctest:
                  iex> 1 + 2
                  3
                      ```
                stacktrace:
                  test/ex_unit/doc_test_test.exs:#{starting_line + 56}: ExUnit.DocTestTest.Invalid (module)
           """

    assert output =~ """
            10) doctest ExUnit.DocTestTest.Invalid.indented_not_enough/0 (10) (ExUnit.DocTestTest.ActuallyCompiled)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                Doctest did not compile, got: (SyntaxError) test/ex_unit/doc_test_test.exs:#{starting_line + 41}:1: unexpected token: "`" (column 1, code point U+0060)
                 #{line_placeholder(starting_line + 41)} |
                 #{starting_line + 41} | `
                 #{line_placeholder(starting_line + 41)} | ^
                doctest:
                  iex> 1 + 2
                  3
                  `
                stacktrace:
                  test/ex_unit/doc_test_test.exs:#{starting_line + 40}: ExUnit.DocTestTest.Invalid (module)
           """

    assert output =~ """
            11) doctest ExUnit.DocTestTest.Invalid.indented_too_much/0 (11) (ExUnit.DocTestTest.ActuallyCompiled)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                Doctest did not compile, got: (SyntaxError) test/ex_unit/doc_test_test.exs:#{starting_line + 49}:3: unexpected token: "`" (column 3, code point U+0060)
                 #{line_placeholder(starting_line + 49)} |
                 #{starting_line + 49} |   ```
                 #{line_placeholder(starting_line + 49)} |   ^
                doctest:
                  iex> 1 + 2
                  3
                    ```
                stacktrace:
                  test/ex_unit/doc_test_test.exs:#{starting_line + 48}: ExUnit.DocTestTest.Invalid (module)
           """

    assert output =~ """
            12) doctest ExUnit.DocTestTest.Invalid.invalid_utf8/0 (12) (ExUnit.DocTestTest.ActuallyCompiled)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                Doctest did not compile, got: (UnicodeConversionError) invalid encoding starting at <<255, 34, 41>>
                stacktrace:
                  test/ex_unit/doc_test_test.exs:#{starting_line + 63}: ExUnit.DocTestTest.Invalid (module)
           """

    assert output =~ """
            13) doctest ExUnit.DocTestTest.Invalid.misplaced_opaque_type/0 (13) (ExUnit.DocTestTest.ActuallyCompiled)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                Doctest did not compile, got: (TokenMissingError) test/ex_unit/doc_test_test.exs:#{starting_line + 69}:7: missing terminator: } (for "{" starting at line #{starting_line + 69})
                 #{line_placeholder(starting_line + 69)} |
                 #{starting_line + 69} | {:ok, #Inspect<[]>}
                 #{line_placeholder(starting_line + 69)} |       ^
                If you are planning to assert on the result of an iex> expression which contains a value inspected as #Name<...>, please make sure the inspected value is placed at the beginning of the expression; otherwise Elixir will treat it as a comment due to the leading sign #.
                doctest:
                  iex> {:ok, :oops}
                  {:ok, #Inspect<[]>}
                stacktrace:
                  test/ex_unit/doc_test_test.exs:#{starting_line + 69}: ExUnit.DocTestTest.Invalid (module)
           """

    assert output =~ "14) doctest ExUnit.DocTestTest.Invalid.raising_inspect/0"
    assert output =~ "iex> ExUnit.DocTestTest.Haiku.new(:this, :is, {:not, :a, :haiku})"

    assert output =~
             "test/ex_unit/doc_test_test.exs:#{starting_line + 82}: ExUnit.DocTestTest.Invalid (module)"

    assert output =~ """
            15) doctest ExUnit.DocTestTest.Invalid.b/0 (15) (ExUnit.DocTestTest.ActuallyCompiled)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                Doctest did not compile, got: (SyntaxError) test/ex_unit/doc_test_test.exs:#{starting_line + 33}:6: syntax error before: '*'
                 #{line_placeholder(starting_line + 33)} |
                 #{starting_line + 33} |  1 + * 1
                 #{line_placeholder(starting_line + 33)} |      ^
                doctest:
                  iex> 1 + * 1
                  1
                stacktrace:
                  test/ex_unit/doc_test_test.exs:#{starting_line + 33}: ExUnit.DocTestTest.Invalid (module)
           """

    assert output =~ """
            16) doctest ExUnit.DocTestTest.Invalid.t/0 (16) (ExUnit.DocTestTest.ActuallyCompiled)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                Doctest did not compile, got: (SyntaxError) test/ex_unit/doc_test_test.exs:#{starting_line + 75}:6: syntax error before: '*'
                 #{line_placeholder(starting_line + 75)} |
                 #{starting_line + 75} |  1 + * 1
                 #{line_placeholder(starting_line + 75)} |      ^
                doctest:
                  iex> 1 + * 1
                  1
                stacktrace:
                  test/ex_unit/doc_test_test.exs:#{starting_line + 75}: ExUnit.DocTestTest.Invalid (module)
           """
  end

  test "pattern matching assertions in doctests" do
    defmodule PatternMatchingRunner do
      use ExUnit.Case
      doctest ExUnit.DocTestTest.PatternMatching, import: true
    end

    doctest_line = __ENV__.line - 3
    starting_line = ExUnit.DocTestTest.PatternMatching.starting_line()

    ExUnit.configure(seed: 0, colors: [enabled: false])
    output = capture_io(fn -> ExUnit.run() end)

    assert output =~ """
             1) doctest module ExUnit.DocTestTest.PatternMatching (1) (ExUnit.DocTestTest.PatternMatchingRunner)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                match (=) failed
                code:  {1, 2} = {1, 3}
                left:  {1, 2}
                right: {1, 3}
                stacktrace:
                  (for doctest at) test/ex_unit/doc_test_test.exs:#{starting_line + 3}: (test)
           """

    assert output =~ """
             2) doctest module ExUnit.DocTestTest.PatternMatching (2) (ExUnit.DocTestTest.PatternMatchingRunner)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                match (=) failed
                code:  {1, 2} = tuple
                left:  {1, 2}
                right: {1, 3}
                stacktrace:
                  (for doctest at) test/ex_unit/doc_test_test.exs:#{starting_line + 6}: (test)
           """

    assert output =~ """
             3) doctest module ExUnit.DocTestTest.PatternMatching (3) (ExUnit.DocTestTest.PatternMatchingRunner)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                match (=) failed
                code:  "Hello, world" = "Hello world"
                left:  "Hello, world"
                right: "Hello world"
                stacktrace:
                  (for doctest at) test/ex_unit/doc_test_test.exs:#{starting_line + 8}: (test)
           """

    assert output =~ """
             4) doctest module ExUnit.DocTestTest.PatternMatching (4) (ExUnit.DocTestTest.PatternMatchingRunner)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                match (=) failed
                code:  "Hello, " <> _ = "Hello world"
                left:  "Hello, " <> _
                right: "Hello world"
                stacktrace:
                  (for doctest at) test/ex_unit/doc_test_test.exs:#{starting_line + 10}: (test)
           """

    assert output =~ """
             5) doctest module ExUnit.DocTestTest.PatternMatching (5) (ExUnit.DocTestTest.PatternMatchingRunner)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                match (=) failed
                code:  [:a | _] = [:b, :a]
                left:  [:a | _]
                right: [:b, :a]
                stacktrace:
                  (for doctest at) test/ex_unit/doc_test_test.exs:#{starting_line + 12}: (test)
           """

    assert output =~ """
             6) doctest module ExUnit.DocTestTest.PatternMatching (6) (ExUnit.DocTestTest.PatternMatchingRunner)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                match (=) failed
                The following variables were pinned:
                  atom = :a
                code:  [^atom | _] = [:b, :a]
                left:  [^atom | _]
                right: [:b, :a]
                stacktrace:
                  (for doctest at) test/ex_unit/doc_test_test.exs:#{starting_line + 15}: (test)
           """

    assert output =~ """
             7) doctest module ExUnit.DocTestTest.PatternMatching (7) (ExUnit.DocTestTest.PatternMatchingRunner)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                match (=) failed
                code:  %{b: _, d: :e} = %{a: :c, d: :e}
                left:  %{b: _, d: :e}
                right: %{a: :c, d: :e}
                stacktrace:
                  (for doctest at) test/ex_unit/doc_test_test.exs:#{starting_line + 17}: (test)
           """

    assert output =~ """
             8) doctest module ExUnit.DocTestTest.PatternMatching (8) (ExUnit.DocTestTest.PatternMatchingRunner)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                match (=) failed
                code:  %{year: 2001, day: 1} = ~D"2000-01-01"
                left:  %{year: 2001, day: 1}
                right: ~D[2000-01-01]
                stacktrace:
                  (for doctest at) test/ex_unit/doc_test_test.exs:#{starting_line + 19}: (test)
           """

    assert output =~ "10 doctests, 8 failures"
  end

  test "IEx prefix contains a number" do
    defmodule NumberedUsage do
      use ExUnit.Case
      doctest ExUnit.DocTestTest.Numbered
    end

    assert capture_io(fn -> ExUnit.run() end) =~ "1 doctest, 0 failures"
  end

  test "IEx prompt contains host" do
    message =
      ~s[unknown IEx prompt: "iex(foo@bar)1> 1 +".\nAccepted formats are: iex>, iex(1)>, ...>, ...(1)>]

    regex = ~r[test/ex_unit/doc_test_test\.exs:\d+: #{Regex.escape(message)}]

    assert_raise ExUnit.DocTest.Error, regex, fn ->
      defmodule HostUsage do
        use ExUnit.Case
        doctest ExUnit.DocTestTest.Host
      end
    end
  end

  test "doctests built-in tags" do
    alias ExUnit.DocTestTest.NoImport

    defmodule DoctestTags do
      use ExUnit.Case, register: false
      doctest NoImport
    end

    assert %ExUnit.TestModule{tests: [test1, test2]} = DoctestTags.__ex_unit__()
    assert %{test_type: :doctest, doctest: NoImport, doctest_line: 129} = test1.tags
    assert %{test_type: :doctest, doctest: NoImport, doctest_line: 132} = test2.tags
  end

  test "multiple exceptions in one test case is not supported" do
    message = ~r"multiple exceptions in the same doctest example are not supported"

    assert_raise ExUnit.DocTest.Error, message, fn ->
      defmodule NeverCompiled do
        import ExUnit.DocTest
        doctest ExUnit.DocTestTest.MultipleExceptions
      end
    end
  end

  test "fails on invalid module" do
    message = ~r"module ExUnit\.DocTestTest\.Unknown is not loaded and could not be found"

    assert_raise CompileError, message, fn ->
      defmodule NeverCompiled do
        import ExUnit.DocTest
        doctest ExUnit.DocTestTest.Unknown
      end
    end
  end

  test "fails when testing single function not found" do
    message = """
    test/ex_unit/doc_test_test\.exs: undefined or private function given to doctest:

        ExUnit.DocTestTest.SomewhatGoodModuleWithOnly.three/0

    """

    assert_raise ExUnit.DocTest.Error, message, fn ->
      defmodule NeverCompiled do
        import ExUnit.DocTest

        doctest ExUnit.DocTestTest.SomewhatGoodModuleWithOnly, only: [three: 0], import: true
      end
    end
  end

  test "fails when testing multiple functions not found" do
    message = """
    test/ex_unit/doc_test_test\.exs: undefined or private functions given to doctest:

        ExUnit.DocTestTest.SomewhatGoodModuleWithOnly.three/0
        ExUnit.DocTestTest.SomewhatGoodModuleWithOnly.four/1

    """

    assert_raise ExUnit.DocTest.Error, message, fn ->
      defmodule NeverCompiled do
        import ExUnit.DocTest

        doctest ExUnit.DocTestTest.SomewhatGoodModuleWithOnly,
          only: [three: 0, four: 1],
          import: true
      end
    end
  end

  test "fails when there are no docs" do
    message = ~r"could not retrieve the documentation for module ExUnit\.DocTestTest"

    assert_raise ExUnit.DocTest.Error, message, fn ->
      defmodule NeverCompiled do
        import ExUnit.DocTest
        doctest ExUnit.DocTestTest
      end
    end
  end

  test "fails in indentation mismatch" do
    message =
      ~r[test/ex_unit/doc_test_test\.exs:\d+: indentation level mismatch on doctest line: \"   iex> bar = 2\".*is exactly 2 spaces]s

    assert_raise ExUnit.DocTest.Error, message, fn ->
      defmodule NeverCompiled do
        import ExUnit.DocTest
        doctest ExUnit.DocTestTest.IndentationMismatchedPrompt
      end
    end

    message =
      ~r[test/ex_unit/doc_test_test\.exs:\d+: indentation level mismatch on doctest line: \"    3\".*is exactly 2 spaces]s

    assert_raise ExUnit.DocTest.Error, message, fn ->
      defmodule NeverCompiled do
        import ExUnit.DocTest
        doctest ExUnit.DocTestTest.IndentationTooMuch
      end
    end

    message =
      ~r[test/ex_unit/doc_test_test\.exs:\d+: indentation level mismatch on doctest line: \"  3\".*is exactly 4 spaces]s

    assert_raise ExUnit.DocTest.Error, message, fn ->
      defmodule NeverCompiled do
        import ExUnit.DocTest
        doctest ExUnit.DocTestTest.IndentationNotEnough
      end
    end
  end

  test "fails on invalid use" do
    assert_raise RuntimeError, ~r"cannot define doctest", fn ->
      defmodule FunctionClashFail do
        import ExUnit.DocTest
        doctest ExUnit.DocTestTest.Invalid
      end
    end
  end

  test "doctest file passing" do
    defmodule FilePassing do
      use ExUnit.Case
      doctest_file(Path.expand("../fixtures/passing.md", __DIR__))
    end

    output = capture_io(fn -> ExUnit.run() end)
    assert output =~ "2 doctests, 0 failures"
  end

  test "doctest file failing" do
    defmodule FileFailing do
      use ExUnit.Case
      doctest_file(Path.expand("../fixtures/failing.md", __DIR__))
    end

    doctest_line = __ENV__.line - 3
    ExUnit.configure(seed: 0, colors: [enabled: false])
    output = capture_io(fn -> ExUnit.run() end)

    assert output =~ """
             1) doctest test/fixtures/failing.md (1) (ExUnit.DocTestTest.FileFailing)
                test/ex_unit/doc_test_test.exs:#{doctest_line}
                Doctest failed
                doctest:
                  iex> 1 + 2
                  4
                code:  1 + 2 === 4
                left:  3
                right: 4
                stacktrace:
                  test/fixtures/failing.md:4: ExUnit.DocTestTest.FileFailing (module)
           """
  end

  defp line_placeholder(line_number) do
    digits =
      line_number
      |> Integer.digits()
      |> length()

    String.duplicate(" ", digits)
  end
end
