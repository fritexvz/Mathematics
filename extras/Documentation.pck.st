'From Cuis 5.0 of 7 November 2016 [latest update: #2974] on 5 January 2017 at 8:15:04 pm'!
'Description Please enter a description for this package'!
!provides: 'Documentation' 1 5!
!classDefinition: #DocumentationGenerator category: #Documentation!
Object subclass: #DocumentationGenerator
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Documentation'!
!classDefinition: 'DocumentationGenerator class' category: #Documentation!
DocumentationGenerator class
	instanceVariableNames: ''!


!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 1/5/2017 09:21:27'!
blacklist
	^ #('Etc' 'Morphic')! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 8/18/2016 03:30'!
copy: aString replaceAll: oldSubstring with: newSubstring
	^ aString lines
		collect: [:each| (each includesSubString: 'http') ifTrue: [each] ifFalse: [each copyReplaceTokens: oldSubstring with: newSubstring]]
		andFold: [:a :b| a, Character lf asString, b]! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 11/2/2016 11:46'!
escape: aString
	| output |
	output _ aString.
	'\[]*{}#<>' do: [:each|
"	'\[]*_{}()#<>' do: [:each|"
		(output includes: each) ifTrue: [output _ output copyReplaceAll: each asString with: '\', each asString]].
	output _ output copyReplaceAll: Character tab asString with: '&nbsp;&nbsp;&nbsp;&nbsp;'.
	output _ output copyReplaceAll: ' _ ' with: ' &larr; '.
	output _ output copyReplaceAll: '^ ' with: '&uarr; '.
	output _ output copyReplaceAll: Character arrowRight asString with: '&rarr;'.
	output _ output copyReplaceAll: Character arrowLeft asString with: '&larr;'.
	output _ output copyReplaceAll: Character arrowUp asString with: '&uarr;'.
	output _ output copyReplaceAll: Character arrowDown asString with: '&darr;'.
	output _ output copyReplaceAll: Character otimes asString with: '&otimes;'.
	output _ output copyReplaceAll: Character oplus asString with: '&oplus;'.
	output _ output copyReplaceAll: Character infinity asString with: '&infin;'.
	output _ output copyReplaceAll: Character emptySet asString with: '&empty;'.
	output _ output copyReplaceAll: Character cup asString with: '&cup;'.
	output _ output copyReplaceAll: Character cap asString with: '&cap;'.
	^ output! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 11/2/2016 11:54'!
escapeCode: aString
	| output |
	output _ aString.
	output _ output copyReplaceAll: ' _ ' with: ' &larr; '.
	output _ output copyReplaceAll: '^ ' with: '&uarr; '.
	output _ output copyReplaceAll: Character arrowRight asString with: '&rarr;'.
	output _ output copyReplaceAll: Character arrowLeft asString with: '&larr;'.
	output _ output copyReplaceAll: Character arrowUp asString with: '&uarr;'.
	output _ output copyReplaceAll: Character arrowDown asString with: '&darr;'.
	output _ output copyReplaceAll: Character otimes asString with: '&otimes;'.
	output _ output copyReplaceAll: Character oplus asString with: '&oplus;'.
	output _ output copyReplaceAll: Character infinity asString with: '&infin;'.
	output _ output copyReplaceAll: Character emptySet asString with: '&empty;'.
	output _ output copyReplaceAll: Character cup asString with: '&cup;'.
	output _ output copyReplaceAll: Character cap asString with: '&cap;'.
	^ output! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 1/5/2017 09:22:21'!
generate
	| classes |
	classes _ Object withAllSubclasses select: [:each| each class ~= Metaclass and: [(each allSuperclasses includes: Morph) not and: [(each category beginsWith: 'Mathematics-') and: [(self blacklist noneSatisfy: [:one| each category includesSubString: one])]]]].
	self generateForClasses: classes.
	self generateIndexByClassCategories! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 8/18/2016 02:57'!
generate: comment references: tokens
	^ self generate: comment references: tokens except: nil! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 9/3/2016 07:12'!
generate: aString references: tokens except: currentToken
	| output |
	output _ self escape: aString.
	tokens do: [:each|
		output _ self copy: output replaceAll: each with: '[',each,'](',each,')'.
		(tokens includes: each, 's') ifFalse:
			[output _ self copy: output replaceAll: each, 's' with: '[',each,'s](',each,')']]
				without: currentToken.
	output _ output copyReplaceAll: Character lf asString with: '  ', Character lf asString.
	^ output! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 12/18/2016 21:20:39'!
generateExampleClass: aClass selector: aSymbol
	| imageFileName source result md canvas textMorph readStream |
	source _ aClass class compiledMethodAt: aSymbol :: getSource.
	readStream _ source readStream.
	readStream nextLine.
	source _ String streamContents: [:writeStream| [readStream atEnd] whileFalse: [readStream peek = Character tab ifTrue: [readStream next]. writeStream nextPutAll: readStream nextLine; lf]].
	md _ '<pre><code>', (self escapeCode: source), '</code></pre>'.
	imageFileName _ aClass name, '-', aSymbol, '.jpg'.
	result _ aClass perform: aSymbol.
	(result isKindOf: Morph)
		ifTrue:
			[canvas _ BitBltCanvas depth: 32 over: (result morphPosition extent: result morphExtent).
			canvas fullDraw: result]
		ifFalse:
			[textMorph _ (TextModelMorph withModel: (TextModel withText: result printText)) wrapFlag: false; findA: InnerTextMorph.
			textMorph color: Color black.
			canvas _ BitBltCanvas depth: 32 over: (textMorph morphPosition extent: textMorph morphExtent).
			canvas fillRectangle: (0@0 extent: textMorph morphExtent + (10@10)) color: Color white. "yellow muchLighter."
			canvas fullDraw: textMorph].
	canvas form writeJPEGfileNamed: self path, imageFileName.
	md _ md, Character lf asString, '&nbsp;&nbsp;&nbsp;&nbsp;!![](doc/', imageFileName, ')'.
	^ md! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 12/18/2016 20:49:19'!
generateForClasses: classes
	| tokens |
	tokens _ classes collect: [:each| each name].
	classes do: [:class|
		| output i file examples |
		output _ '' writeStream.
		class withAllSuperclasses reversed do: [:each|
			| generated |
			generated _ each == class
				ifTrue: ['**', each name, '**']
				ifFalse: [self generate: each name references: tokens].
			output nextPutAll: generated]
			separatedBy: [output nextPutAll: ' > '].
		output lf; lf.
		class hasComment ifTrue: [output nextPutAll: (self generate: class comment references: tokens except: class name); lf; lf].
		output nextPutAll: '***'; lf.
		
		examples _ class class organization listAtCategoryNamed: #examples.
		examples _ examples select: [:each| each isUnary].
		examples notEmpty ifTrue:
			[examples do: [:exampleSelector|
				output nextPutAll: (self generateExampleClass: class selector: exampleSelector); lf; lf].
				output nextPutAll: '***'; lf].
"		class organization categories do: [:category|
			((category includesSubString: 'private') or: [category includesSubString: 'initializ'])
				ifFalse:
					[output nextPutAll: '*', category withBlanksTrimmed, '*  '; lf.
					(class organization listAtCategoryNamed: category)
						do: [:selector|
							| methodComment |
							output nextPutAll: '&nbsp;&nbsp;**',(self escape: (class sourceCodeAt: selector) lines first withBlanksTrimmed),'**  '; lf.
							(methodComment _ class firstCommentAt: selector) isEmpty
								ifFalse: [methodComment lines do: [:line| output nextPutAll: '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;', (self escape: line withBlanksTrimmed), '  '; lf]].
							output lf]]].
		output nextPutAll: '***'; lf."
		i _ 0.
		class allSuperclasses reversed do: [:each|
			i*2 timesRepeat: [output nextPutAll: '&nbsp;'].
			output nextPutAll: (self generate: each name references: tokens).
			output nextPutAll: '  '; lf.
			i _ i + 1].
		class allSubclassesWithLevelDo: [:subclass :level|
			| generated |
			(classes includes: subclass) ifTrue:
				[(level+i)*2 timesRepeat: [output nextPutAll: '&nbsp;'].
				generated _ subclass == class
					ifTrue: ['**', subclass name, '**']
					ifFalse: [self generate: subclass name references: tokens].
				output nextPutAll: generated.
				output nextPutAll: '  '; lf]] startingLevel: 0.
		file _ self path,class name,'.md' :: asFileEntry.
		file assureExistence; fileContents: output contents]! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 1/5/2017 12:17:33'!
generateIndexByClassCategories
	| categories output file |
	categories _ Smalltalk organization categories select: [:each| (each beginsWith: 'Mathematics-') and: [self blacklist noneSatisfy: [:one| each includesSubString: one]]].
	output _ '' writeStream.
	categories do: [:category|
		output nextPutAll: '**', (category withoutPrefix: 'Mathematics-'), '**'; lf; lf.
		(Smalltalk organization listAtCategoryNamed: category) do: [:each|
			8 timesRepeat: [output nextPutAll: '&nbsp;'].
			output nextPutAll: '[', each asString, '](', each asString, ')'; space]]
		separatedBy: [output lf; lf].
	file _ self path, 'index.md' :: asFileEntry.
	file assureExistence; fileContents: output contents! !

!DocumentationGenerator methodsFor: 'as yet unclassified' stamp: 'len 8/11/2016 21:58'!
path
	^ '/home/guest/cuis/Cuis-Mathematics.wiki/doc/'! !
