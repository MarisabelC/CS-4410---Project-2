import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;


public class Trie {

	private int _switch[];
	private List<Character> symbol;
	private List <Integer> next; 
	private String newIdentifier;
	private int nextPos;

	public Trie() {
		_switch= new int[52];
		symbol= new ArrayList<>(1000);
		next= new ArrayList<>(1000);
		initSwitch();
	}

	/**
	 *Initialize the switch table. Set all value to -1 
	 */
	private void initSwitch() {
		for (int i=0;i<_switch.length;i++)
			_switch[i]=-1;
	}

	/**
	 * Check if the character is upper case
	 * @param nextChar the character to be checked
	 * @return true if the character is upper case otherwise false.
	 */

	private boolean isUpper(char nextChar) {
		return nextChar >= 'A' && nextChar <= 'Z';
	}

	/**
	 * Check if the character is lower case 
	 * @param nextChar the character to be checked
	 * @return true if it is lower case otherwise false.
	 */
	private boolean isLower(char nextChar) {
		return nextChar >= 'a' && nextChar <= 'z';
	}

	/**
	 * Get the position that correspond to the character in the switch table 
	 * @param nextChar character of an identifier
	 * @return the position on the switch table 
	 */
	private int getValue(char nextChar) {
		int value=-1;
		if (nextPos<newIdentifier.length() && (isUpper(nextChar) ||isLower(nextChar))) {
			if (isUpper(nextChar)) //position: 0-25 in the switch array.
				value = nextChar-'A';
			else if (isLower(nextChar)) // position: 26 - 51 in the switch array.
				value = nextChar - 'G'; 
			return value;
		}
		throw new NoSuchElementException("charater: "+ nextChar +" must be an alphabeth character");
	}

	/**
	 * Add the identifier to the tables
	 * @param identifier the name of the identifier to be added
	 */
	public void addIdentifier(String identifier) {
		searchCreateIdentifier(identifier,'@');
	}

	/**
	 * Add the keyword to the table
	 * @param keyword the name of the keyword to be added
	 */
	public void addKeyword(String keyword) {
		searchCreateIdentifier(keyword,'*');
	}

	/**
	 * Search if the keyword or identifier is in the table. If it is not in the table, create an entry.
	 * @param identifier the name of the identifier or keyword
	 * @param endMarker "*" is for and keyword, "@" is for the identifier
	 */
	private void searchCreateIdentifier(String identifier, char endMarker) {
		newIdentifier= identifier+Character.toString(endMarker); ;
		nextPos=0;
		boolean exit=false;
		char valueOfSymbol= newIdentifier.charAt(nextPos);
		int ptr=_switch[getValue(valueOfSymbol)];

		nextPos++;
		if (ptr == -1) {
			createIdentifier(getValue(valueOfSymbol),false);
		}else {
			valueOfSymbol= newIdentifier.charAt(nextPos);
			while (!exit) {
				if (symbol.get(ptr).equals(valueOfSymbol) && nextPos<identifier.length()){
					ptr++;
					nextPos++;
					valueOfSymbol= newIdentifier.charAt(nextPos);
				}
				else { 
					if (next.get(ptr) !=-1) 
						ptr= next.get(ptr);
					else if (valueOfSymbol==endMarker && (symbol.get(ptr)=='@' || symbol.get(ptr)=='*') ) 
						break;
					else {	
						createIdentifier(ptr,true);
						exit=true;
					}
				}
			}
		}	
	}

	/**
	 * Add the position that corresponds to the identifier or keyword 
	 * in the switch table or the next table.
	 * @param position that corresponds to the identifier or keyword
	 * @param hasPrevious set false if the first character of the identifier is not in the switch table
	 * otherwise true.
	 */
	private void createIdentifier(int position,boolean hasPrevious) {

		if (!hasPrevious)
			_switch[position]=symbol.size();
		else 
			next.set(position,symbol.size());
		addCharToSymbol();

	}

	/**
	 * Add the characters to the symbol table.
	 */
	private void addCharToSymbol() {
		for (int i=nextPos;i<newIdentifier.length();i++) {
			symbol.add(newIdentifier.charAt(i));
			next.add(-1);
		}
	}

	/**
	 * Print the switch, symbol and next tables
	 */
	public void printTable() {
		printSwitchTable();
		printNextSymbolTable();
	}

	/**
	 * Print the switch table.
	 */
	private void printSwitchTable() {
		int start=0;
		int i=0;
		System.out.printf("%n%10s","");
		for (;i<_switch.length;i++) {
			//print label	
			if (i ==0 || i%20!=0) { //Each row contains 19 entries or less
				if (isUpper((char)(i+'A'))) 
					System.out.printf("%6s", (char)(i+'A')); //Print A-Z
				else {
					System.out.printf("%6s", (char)(i+'G')); //Print a-z
				}
			}else {
				System.out.println();
				System.out.printf("%10s","switch:");
				for (int j= start;j<i;j++){
					System.out.printf("%6d",_switch[j]);
				}
				start=i;
				System.out.printf("%n%n%10s","");
				if (isUpper((char)(i+'A'))) 
					System.out.printf("%6s", (char)(i+'A'));
				else {
					System.out.printf("%6s", (char)(i+'G'));
				}
			}	
		}
		System.out.printf("%n%10s","switch:");
		for (int j= start;j<_switch.length;j++){
			System.out.printf("%6d",_switch[j]);
		}
		System.out.println("\n");

	}

	/**
	 *Print the next and symbol tables.
	 */
	private void printNextSymbolTable() {
		int start=0;
		int i=0;
		System.out.printf("%n%n%10s","");
		for (;i<symbol.size();i++) {
			//print label
			if (i ==0 || i%20 != 0) {	//Each row contains 19 entries or less
				System.out.printf("%6d", i);
			}else {
				System.out.printf("%n%10s","symbol:");
				for (int j= start;j<i;j++){
					System.out.printf("%6s",symbol.get(j));
				}
				System.out.printf("%n%10s","next:");
				for (int j= start;j<i;j++){
					if (next.get(j) != -1)
						System.out.printf("%6d",next.get(j));
					else
						System.out.printf("%6s","");
				}
				start=i;
				System.out.printf("%n%n%n%10s%6d","",i);
			}
		}
		System.out.printf("%n%10s","symbol:");
		for (int j= start;j<i;j++){
			System.out.printf("%6s",symbol.get(j));
		}
		System.out.printf("%n%10s","next:");
		for (int j= start;j<i;j++){
			if (next.get(j) != -1)
				System.out.printf("%6d",next.get(j));
			else
				System.out.printf("%6s","");
		}
		System.out.println();
	}




}
