defmodule ConsumersIncludeMatchTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State
  alias ExCss.Lexer.Tokens

  describe ".accept" do
    context "not starting with a ~" do
      it "returns no token and doesn't advance the state" do
        {new_state, token} = ExCss.Lexer.Consumers.IncludeMatch.accept(State.new("abc"))
        expect(new_state.i) |> to_eq(-1)
        expect(token) |> to_be_nil
      end
    end

    context "starts with a ~" do
      context "but not followed by a =" do
        it "returns a delim of ~ and advances 1 char" do
          {new_state, token} = ExCss.Lexer.Consumers.IncludeMatch.accept(State.new("~abc"))
          expect(new_state.i) |> to_eq(0)
          expect(token) |> to_eq(%Tokens.Delim{value: "~"})
        end
      end

      context "followed by a =" do
        it "returns a include match and advances 2 chars" do
          {new_state, token} = ExCss.Lexer.Consumers.IncludeMatch.accept(State.new("~=abc"))
          expect(new_state.i) |> to_eq(1)
          expect(token) |> to_eq(%Tokens.IncludeMatch{})
        end
      end
    end
  end
end
