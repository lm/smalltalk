"======================================================================
|
|   SQLite bindings, Statement class
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2007 Free Software Foundation, Inc.
| Written by Daniele Sciascia
|
| This is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
|
| This code is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
|
| You should have received a copy of the GNU General Public License along with
| Mumble; see the file COPYING.  If not, write to the Free Software
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
|
 ======================================================================
"



Statement subclass: SQLiteStatement [
    | handle queryString isSelect |
    
    <category: 'DBI-Drivers'>
    <comment: 'I represent a SQLite prepared statement'>
    
    SelectQueries := #('EXPLAIN' 'SELECT') asSet.

    handle [
        <category: 'private'>
        ^handle
    ]
    
    handle: aSqlite3StmtHandle [
        <category: 'private'>
        handle := aSqlite3StmtHandle
    ]
    
    queryString [
        <category: 'accessing'>
        ^queryString
    ]
    
    queryString: aSQLQuery [
        <category: 'accessing'>
        queryString := aSQLQuery.
        
    ]
    
    isSelect [
        <category: 'accessing'>
        isSelect isNil
            ifTrue: [isSelect := SelectQueries includes: self getCommand].
        ^isSelect
    ]
    
    execute [
	    <category: 'querying'>
        ^SQLiteResultSet on: self
    ]
    
    executeWithAll: aParams [
        <category: 'querying'>
	    self notYetImplemented
    ]
    
    getCommand [
        <category: 'private'>
        | readStream writeStream aCharacter |
        writeStream := WriteStream on: String new.
        readStream := ReadStream on: queryString.
        readStream skipSeparators.
        [readStream atEnd
	    or: [aCharacter := readStream next. aCharacter isSeparator]]
                whileFalse: [writeStream nextPut: aCharacter asUppercase].
        ^writeStream contents
    ]
]