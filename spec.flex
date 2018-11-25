import java.util.ArrayList;
import java.io.*;
import java_cup.runtime.*;

%%

%{
  	private int comment_count = 0;
  	private ArrayList<String> tokens = new ArrayList<>();
  	String keywords[]= {"boolean", "break", "class", "double","else", "extends", "false", "for", "if", "implements", "int", "interface", "new", "newarray", "null", "println", "readln", "return", "string", "true", "void", "while"};
  	Trie trie = new Trie();
  	private String fileName;
%} 

%init{
  	for (int i=0;i<keywords.length;i++) {
  		trie.addKeyword(keywords[i]);
  	}	
%init}

%eof{
	try {
		FileWriter fileWriter = new FileWriter(fileName);
		BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);
		boolean _newline = true;
		for (int i = 0; i < tokens.size(); i++) {
			if (!_newline) {
				System.out.print(" ");
				bufferedWriter.write(" ");
			}
			if (_newline && tokens.get(i).equals("\n")) {
				continue;
			}
			System.out.print(tokens.get(i));
			bufferedWriter.write(tokens.get(i));
			if (tokens.get(i).equals("\n")) {
				_newline = true;
			} else {
				_newline = false;
			}
		} 
	}
	catch (IOException ex) {
		System.out.println("Error writing to file " + fileName);

	System.out.println("");

	trie.printTable();
	}

%eof}

%class Lexer
%column
%cup
%cupsym sym
%line
%unicode
%state COMMENT
%debug
%ignorecase
%type Symbol



ALPHA=[A-Za-z]
DIGIT=[0-9]
NONNEWLINE_WHITE_SPACE_CHAR=[\ \t\b\012]
NEWLINE=\r|\n|\r\n
WHITE_SPACE_CHAR=[\n\r\ \t\b\012]
STRING_TEXT=(\\\"|[^\n\r\"]|\\{WHITE_SPACE_CHAR}+\\)*
COMMENT_TEXT=([^*/\n]|[^*\n]"/"[^*\n]|[^/\n]"*"[^/\n]|"*"[^/\n]|"/"[^*\n])+
Ident = {ALPHA}({ALPHA}|{DIGIT}|_)*
HEX_INTEGER = ("0X"|"0x")[0-9A-Fa-f]+
DOUBLE = ({DIGIT}+"."{DIGIT}*)(([Ee]([+-]?({DIGIT}+)))?)
BOOLEAN_CONSTANT = "true"|"false"

%%

<YYINITIAL> {
  "+" { tokens.add("plus");
  	return (new Symbol(sym._plus,yychar,yychar + yytext().length(), yytext())); }
  "-" { tokens.add("minus");
  	return (new Symbol(sym._minus,yychar,yychar + yytext().length(), yytext())); }
  "*" { tokens.add("multiplication"); 
  	return (new Symbol(sym._multiplication,yychar,yychar + yytext().length(), yytext())); }
  "/" { tokens.add("division"); 
  	return (new Symbol(sym._division,yychar,yychar + yytext().length(), yytext())); }
  "%" { tokens.add("mod"); 
  	return (new Symbol(sym._mod,yychar,yychar + yytext().length(), yytext())); }
  "<"  { tokens.add("less");
  	return (new Symbol(sym._less,yychar,yychar + yytext().length(), yytext())); }
  "<=" { tokens.add("lessequal");
  	return (new Symbol(sym._lessequal,yychar,yychar + yytext().length(), yytext())); }
  ">"  { tokens.add("greater");
  	return (new Symbol(sym._greater,yychar,yychar + yytext().length(), yytext())); }
  ">=" { tokens.add("greaterequal");
  	return (new Symbol(sym._greaterequal,yychar,yychar + yytext().length(), yytext())); }
  "==" { tokens.add("equal");
  	return (new Symbol(sym._equal,yychar,yychar + yytext().length(), yytext())); }
  "!=" { tokens.add("notequal");
  	return (new Symbol(sym._notequal,yychar,yychar + yytext().length(), yytext())); }
  "&&"  { tokens.add("and");
  	return (new Symbol(sym._and,yychar,yychar + yytext().length(), yytext())); }
  "||"  { tokens.add("or");
  	return (new Symbol(sym._or,yychar,yychar + yytext().length(), yytext())); }
  "!" { tokens.add("not");
  	return (new Symbol(sym._not,yychar,yychar + yytext().length(), yytext())); }
  "=" { tokens.add("assignop");
  	return (new Symbol(sym._assignop,yychar,yychar + yytext().length(), yytext())); }
  ";" { tokens.add("semicolon");
  	return (new Symbol(sym._semicolon,yychar,yychar + yytext().length(), yytext())); }
  "," { tokens.add("comma");
  	return (new Symbol(sym._comma,yychar,yychar + yytext().length(), yytext())); }
  "." { tokens.add("period");
  	return (new Symbol(sym._period,yychar,yychar + yytext().length(), yytext())); }
  "(" { tokens.add("leftparen");
  	return (new Symbol(sym._leftparen,yychar,yychar + yytext().length(), yytext())); }
  ")" { tokens.add("rightparen");
  	return (new Symbol(sym._rightparen,yychar,yychar + yytext().length(), yytext())); }
  "[" { tokens.add("leftbracket");
  	return (new Symbol(sym._leftbracket,yychar,yychar + yytext().length(), yytext())); }
  "]" { tokens.add("rightbracket");
  	return (new Symbol(sym.rightbracket,yychar,yychar + yytext().length(), yytext())); }
  "{" { tokens.add("leftbrace");
  	return (new Symbol(sym._leftbrace,yychar,yychar + yytext().length(), yytext())); }
  "}" { tokens.add("rightbrace");
  	return (new Symbol(sym._rightbrace,yychar,yychar + yytext().length(), yytext())); }


  {NONNEWLINE_WHITE_SPACE_CHAR}+ { }

  "/*" { yybegin(COMMENT); comment_count++; }
  "//".* {}

  \"{STRING_TEXT}\" {
  	tokens.add("stringconstant");
    String str =  yytext().substring(1,yylength()-1);
    return (new Symbol(sym._stringconstant,str,yyline,yychar,yychar+yylength()));
  }
  
  \"{STRING_TEXT} {
    String str =  yytext().substring(1,yytext().length());
    Utility.error(Utility.E_UNCLOSEDSTR);
    return (new Symbol(sym.error,str,yyline,yychar,yychar + str.length()));
  } 
  
  {DIGIT}+ { 
  	tokens.add("intconstant");
  	return (new Symbol(sym._intconstant,yytext(),yyline,yychar,yychar+yylength())); 
  }  

  {HEX_INTEGER} {
  	tokens.add("intconstant");
  	return (new Symbol(sym._intconstant,yytext(),yyline,yychar,yychar+yylength())); 
  }

  {DOUBLE} {
  	tokens.add("doubleconstant");
  	return (new Symbol(sym._doubleconstant,yytext(),yyline,yychar,yychar+yylength()));
  }

  {BOOLEAN_CONSTANT} {
  	tokens.add("booleanconstant");
  	return (new Symbol(sym._booleanconstant,yytext(),yyline,yychar,yychar+yylength()));
  }

  {Ident} { 
  	String t = yytext();
  	if (t.equals("boolean")) {
  		tokens.add("boolean");
  		return (new Symbol(sym._boolean,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("break")) {
		tokens.add("break");
  		return (new Symbol(sym._break,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("class")) {
		tokens.add("class");
  		return (new Symbol(sym._class,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("double")) {
		tokens.add("double");
  		return (new Symbol(sym._double,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("else")) {
		tokens.add("else");
  		return (new Symbol(sym._else,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("extends")) {
		tokens.add("extends");
  		return (new Symbol(sym._extends,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("for")) {
		tokens.add("for");
  		return (new Symbol(sym._for,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("if")) {
		tokens.add("if");
  		return (new Symbol(sym._if,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("implements")) {
		tokens.add("implements");
  		return (new Symbol(sym._implements,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("int")) {
		tokens.add("int");
  		return (new Symbol(sym._int,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("interface")) {
		tokens.add("interface");
  		return (new Symbol(sym._interface,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("new")) {
		tokens.add("new");
  		return (new Symbol(sym._new,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("newarray")) {
		tokens.add("newarray");
  		return (new Symbol(sym._newarray,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("null")) {
		tokens.add("null");
  		return (new Symbol(sym._null,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("println")) {
		tokens.add("println");
  		return (new Symbol(sym._println,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("readln")) {
		tokens.add("readln");
  		return (new Symbol(sym._readln,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("return")) {
		tokens.add("return");
  		return (new Symbol(sym._return,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("string")) {
		tokens.add("string");
  		return (new Symbol(sym._string,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("void")) {
		tokens.add("void");
  		return (new Symbol(sym._void,yytext(),yyline,yychar,yychar+yylength()));
  	} else if (t.equals("while")) {
		tokens.add("while");
  		return (new Symbol(sym._while,yytext(),yyline,yychar,yychar+yylength()));
  	} else {
  		tokens.add("id");
  		trie.addIdentifier(t);
  	  	return (new Symbol(sym._id,yytext(),yyline,yychar,yychar+yylength()));
  	}

  }  
}

<COMMENT> {
  "/*" { comment_count++; }
  "*/" { if (--comment_count == 0) yybegin(YYINITIAL); }
  {COMMENT_TEXT} { }
}


{NEWLINE} { 
	tokens.add("\n");
}

. {
  System.out.println("Illegal character: <" + yytext() + ">");
	Utility.error(Utility.E_UNMATCHED);
}