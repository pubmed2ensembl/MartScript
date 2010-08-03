package org.bergmanlab.martscript;

import java.util.*;

public class Action {
	public String name;
	public List parameters;
	
	public Action(String name, List parameters) {
		this.name = name;
		this.parameters = parameters;
	}
	
	public String toString() {
		return name + " " + parameters;
	}
}

