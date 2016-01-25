defmodule ExCss.Lexer.Consumers.SubstringMatch do
  alias ExCss.Lexer.Tokens
  alias ExCss.Lexer.State

  def accept(state) do
    if State.peek(state) == "*" do
      state = State.consume(state)
      if State.peek(state) == "=" do
        state = State.consume(state)
        {state, %Tokens.SubstringMatch{}}
      else
        {state, %Tokens.Delim{value: state.grapheme}}
      end
    else
      {state, nil}
    end
  end
end
