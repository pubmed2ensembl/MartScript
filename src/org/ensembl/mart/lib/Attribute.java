/* Generated by Together */

/*
    Copyright (C) 2003 EBI, GRL

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
 */

package org.ensembl.mart.lib;

/**
 * Interface for all Attributes, defining standard behavior of the object
 * for use by a Query.
 * 
 * @author <a href="mailto:craig@ebi.ac.uk">Craig Melsopp</a>
 * @author <a href="mailto:dlondon@ebi.ac.uk">Darin London</a>
 */
public interface Attribute extends Field {

	/**
	 * @param attribute attribute to compare to.
	 * @return true if field and tableconstraint are the same as the
   * attribute.
	 */
	boolean sameFieldTableConstraint(Attribute attribute);
	
}