from pygments.lexer import RegexLexer
from pygments.token import Token

class MMLLexer(RegexLexer):
    name = "MML"
    aliases = ["mml"]
    
    tokens = {
        'root' : [
            (r'\s+', Token.Text.Whitespace),
            *[(k, Token.Keyword.Declaration) for k in [r'import', r'define', r'assume', r'show']],
            *[(k, Token.Keyword) for k in [r'forall', r'exists', r'fun', r'if', r'then', r'_import_', r'_define_', r"_import_", r"_define_", r"_assume_", r"_show_", r"_forall_", r"_exists_", r"_fun_", r"_if_", r"_then_", "_->_", "as","and", "or"]],
            (r'\S+', Token.Text),
        ]
    }




def setup(app):
    app.add_lexer('mml', MMLLexer)
    app.add_lexer('mmlc', MMLLexer)