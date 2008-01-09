"======================================================================
|
|   SQLite bindings, ResultSet class
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


ResultSet subclass: SQLiteResultSet [
    | handle rows columns index |
		   
    SQLiteResultSet class >> on: aStatement [
        <category: 'instance creation'>
        ^self new initializeWithStatement: aStatement
    ]
    
    initializeWithStatement: aStatement [
        <category: 'initialization'>
        index := 0.
        self statement: aStatement.
        self handle: (aStatement handle).
        self isSelect
	    ifTrue: [self populate]
	    ifFalse: [self exec]
    ]
    
    exec [
        <category: 'initialization'>
	| resCode |
        resCode := self handle exec.
        self handle checkError: resCode = 101.
	rows := handle changes
    ]

    populate [
        <category: 'initialization'>
        | resCode |
        
        rows := OrderedCollection new.
        [ resCode := self handle exec.
          resCode = 100
        ] whileTrue: [rows addLast: 
                        (SQLiteRow forValues: (self handle returnedRow) in: self)].
        
        self handle checkError: resCode = 101.
    ]
    
    handle [
        <category: 'private'>
        ^handle
    ]
    
    handle: aSQLite3StmtHandle [
        <category: 'private'>
        handle := aSQLite3StmtHandle
    ]

    next [
        <category: 'cursor access'>
    	self atEnd ifTrue: [self error: 'No more rows'].
    	index := index + 1.
    	^self rows at: index
    ]

    atEnd [
        <category: 'cursor access'>
        ^index >= self rowCount
    ]
    
    position [
        <category: 'stream protocol'>
        ^index
    ]

    position: anInteger [
        <category: 'stream protocol'>
        (anInteger between: 0 and: self size)
            ifTrue: [ index := anInteger ] 
            ifFalse: [ SystemExceptions.IndexOutOfRange signalOn: self withIndex: anInteger ].
        ^index
    ]

    columns [
        <category: 'accessing'>
        columns isNil
            ifTrue: [| n |
                     n := self handle colCount.
                     columns := LookupTable new: n.
                     1 to: n do: [:i | columns at: (self columnNames at: i)
                                               put: (SQLiteColumnInfo in: self at: i)]].
        ^columns
    ]

    columnNames [
        <category: 'accessing'>
        ^self handle colNames
    ]
    
    columnTypes [
        ^self handle colTypes
    ]
    
    columnTypeAt: index [
        ^self columnTypes at: index
    ]

    isSelect [
        <category: 'accessing'>
	^self statement isSelect
    ]

    isDML [
        <category: 'accessing'>
	^self statement isSelect not
    ]
    
    rows [
        <category: 'accessing'>
        ^rows
    ]

    rowCount [
        <category: 'accessing'>
        self isSelect 
            ifTrue: [^self rows size]
            ifFalse: [^self error: 'Not a SELECT statement.']
    ]

    rowsAffected [
        <category: 'accessing'>
        self isDML 
            ifTrue: [^self rows]
            ifFalse: [^self error: 'Not a DML statement.']
    ]
]