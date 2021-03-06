defmodule ExCss.Parser.Nodes.DeclarationList do
  alias ExCss.Utils.PrettyPrint

  alias ExCss.Parser.State
  alias ExCss.Parser.Nodes, as: N
  alias ExCss.Lexer.Tokens, as: T
  alias ExCss.Lexer.Token

  defstruct value: []

  def pretty_print(declaration_list, indent) do
    PrettyPrint.pretty_out("Declaration List:", indent)
    PrettyPrint.pretty_out("Declarations:", indent + 1)
    PrettyPrint.pretty_out(declaration_list.value, indent + 2)
  end

  def parse(state) do
    {state, declarations} = consume_a_list_of_declarations(state)
    {state, %N.DeclarationList{value: declarations}}
  end

  defp consume_a_list_of_declarations(state) do
    state |> State.debug("-- CONSUMING A LIST OF DECLARATIONS --")
    {state, list} = consume_a_list_of_declarations(state, [])

    {state, Enum.reverse(list)}
  end
  defp consume_a_list_of_declarations(state, declarations) do
    # Create an initially empty list of declarations.
    #
    # Repeatedly consume the next input token:
    #
    # <whitespace-token>
    # <semicolon-token>
    # Do nothing.
    # <EOF-token>
    # Return the list of declarations.
    # <at-keyword-token>
    # Consume an at-rule. Append the returned rule to the list of declarations.
    # <ident-token>
    # Initialize a temporary list initially filled with the current input token.
    # Consume the next input token. While the current input token is anything other than a
    # <semicolon-token> or <EOF-token>, append it to the temporary list and consume the next input token.
    # Consume a declaration from the temporary list. If anything was returned, append it to the list of declarations.
    # anything else
    # This is a parse error. Repeatedly consume a component value until it is a <semicolon-token> or <EOF-token>.

    state = State.consume_whitespace(state)

    case Token.type(state.token) do
      T.EndOfFile ->
        {state, declarations}
      T.Semicolon ->
        consume_a_list_of_declarations(State.consume(state), declarations)
      T.Comment ->
        consume_a_list_of_declarations(State.consume(state), declarations)
      T.AtKeyword ->
        {state, at_rule} = N.AtRule.parse(state)
        consume_a_list_of_declarations(state, [at_rule] ++ declarations)
      T.Id ->
        {state, temp_list} = consume_temp_list_for_declaration(state)

        temp_state = State.new(temp_list)

        {_, declaration} = N.Declaration.parse(temp_state)

        if declaration do
          declarations = [declaration] ++ declarations
        end

        consume_a_list_of_declarations(state, declarations)
    end
  end

  defp consume_temp_list_for_declaration(state, temp_list \\ []) do
    if State.currently?(state, [T.EndOfFile, T.Semicolon]) do
      {State.consume(state), temp_list}
    else
      {state, component_value} = State.consume_component_value(state)
      consume_temp_list_for_declaration(state, temp_list ++ [component_value])
    end
  end
end
