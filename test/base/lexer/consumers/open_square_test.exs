defmodule ConsumersOpenSquareTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  alias ExCss.Lexer.State
  alias ExCss.Lexer.Tokens

  describe ".accept" do
    context "doesn't match [" do
      it "returns an unchanged state and no token" do
        {new_state, token} = ExCss.Lexer.Consumers.OpenSquare.accept(State.new("[abc]", 0))
        expect(new_state.i) |> to_eq(0)
        expect(token) |> to_be_nil
      end
    end

    context "matches ]" do
      it "returns an open square advances 1 char" do
        {new_state, token} = ExCss.Lexer.Consumers.OpenSquare.accept(State.new("[abc]"))
        expect(new_state.i) |> to_eq(0)
        expect(token) |> to_eq(%Tokens.OpenSquare{})
      end
    end
  end
end
