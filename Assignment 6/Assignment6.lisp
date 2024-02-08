;1. myList function which returns a list
(defun myList ()
  ;(list 4 '(7 22) "art" '("math" (8) 99) 100)
  (cons 4 (cons '(7 22) (cons "art" (cons '("math" (8) 99) (cons 100 '())))))
)

;2. leapYear function which calculates and returns the leap years between 1800 and 2020
(defun leapYear(&optional (checkYear 1800) (leapYears '()))
  ;leap years are years that are multiples or 400 or are a multiple of 4 but not a multiple of 100
  (cond ( (< 2021 checkYear  ) leapYears)
   ;check if checkYear is a leap year or not. If it isn't a leap year, don't add it to the list
   ;and increment checkYear
   ( ( and (/= (mod checkYear 400) 0 ) ;if not divisible by 400
 	   (= (mod checkYear 100) 0 )  ;and is divisible by 100
 	   (= (mod checkYear 4) 0 ) )  ;and is divisible by 4
	   ( leapYear (+ 4 checkYear) leapYears)) ;then it isn't a leap year
   ;otherwise it is a leap year, so we append the year to the list
   ( (leapYear (+ 4 checkYear) ( append leapYears (list checkYear) ) ) ) 
  ) ;end of cond
)

;3. union- function which creates the set theoretic union of two sets
(defun union- (list1 list2 &optional unionedList)
 ;checkExclusive will let us check if an element is in the list currently
 (labels ((checkExclusive (checkElement checkList)
   ;if the list to check is empty, then checkElement is not in it
   (cond ((null checkList) T)
	 ;if checkElement is equal to the head of checkList, don't add it
	 ((eql checkElement (car checkList)) NIL)
	 ;else compare checkElement to the next element of checkList
	 ((checkExclusive checkElement (cdr checkList)))
	 );end of cond
   ))

 (cond 
  ; first add list1 to the union, then empty list1. Since unionedList starts out empty, all of list1 can be added
  ( (not (null list1)) (union- '() list2 (append unionedList list1)))
  ; if both lists are empty, return unionedList
  ((and (null list1) (null list2)) unionedList)
  ; if the next element of list2 can be added to unionedList, add it and look at the next element
  ((checkExclusive (car list2) unionedList ) (union- '() (cdr list2) (append unionedList (list (car list2)))))
  ; otherwise don't add the element and look at the next element of list2
  ( (not (checkExclusive (car list2) unionedList) ) (union- '() (cdr list2) unionedList))
 )
 )
)

;4. avg function which finds the average of a list of numbers
;this function is tail recursive and returns NIL if an empty list is input
(defun avg (aList &optional (sum 0) (numTerms 0))
 ;if the list started out empty, return NIL
 (cond ( (and (null aList) (= numTerms 0) ) NIL)
  	;if the list is empty but numTerms is nonzero, then return the avergae
 	((null aList) (/ sum numTerms))
  	;else add the next element to the average and continue
	((avg (cdr aList) (+ sum (car aList)) (+ 1 numTerms)))
 )
)

;5. isType function which returns an anonymous function that checks
;if the data type of its argument is equal to that of dataType
(defun isType (dataType)
  	;typep is a function that returns true if two objects have the same type
	(lambda (checkType) (typep checkType dataType))
)

;6. taxCalculator function which takes in a list, a limit, and a tax rate
;and returns a list where any values > limit are multiplied by rate
(defun taxCalculator (limit rate vals &optional taxedVals)
  ;if values is empty, return taxedVals
  (cond ( (null vals) taxedVals)
	;otherwise there are still values in values to look at
	;if the number in values is > limit, multiply it by rate and add it to taxedValues
	( (< limit (car vals)) (taxCalculator limit rate (cdr vals) (append taxedVals (list (* (car vals) rate))) ))
	;if the number in values is <= limit, add it to taxedValues without multiplying
	( (>= limit (car vals)) (taxCalculator limit rate (cdr vals) (append taxedVals (list (car vals))) ))
  )
)

;7. clean function which takes in a function and list and "cleans" the list of
;and values that return false when input into aFunc
;sublists are also taken into account
(defun clean (aFunc aList )
  ;if the list is empty, return NIL
  (cond ((null aList) NIL)
	;we need to check if aList starts with a sublist
	;the consp function checks if an object is a cons cell - allows us to check for sublists
	;each sublist must then be cleaned and we reconnect the sublists using cons
	;using cons makes sure the order and structure stays the same
	( (consp (car aList)) (cons (clean aFunc (car aList)) (clean aFunc (cdr aList))))
	;if aFunc returns true on the first element on the list, create a cons cell with
	;the head of the list followed by the rest of the cleaned list
	( (funcall aFunc (car aList)) (cons (car aList) (clean aFunc (cdr aList))))
	;otherwise remove the head of the list and clean the rest of the list
	( (clean aFunc (cdr aList)))
  )
)

;8. macro which executes one of three sublists of toExecute depending on
;values of numbers x and y. (< x y) -> 1st sublist, (> x y) -> 2nd sublist
;and (= x y) -> 3rd sublist
(defmacro threeWayBranch (x y toExecute)
  ;executesSublist allows us to execute whichever sublist is chosen by the cond statement
  (labels ((executeSublist (exe)
    (cond ((null exe) NIL)
	  ;progn evaluates lists of expressions
	  ;since it only keeps the evaluations of the last element in a list,
	  ;we have to give it one element at a time
	  ((progn (car exe)) (executeSublist (cdr exe)))
    )))

  ;compare x and y and choose the first, second, or third sublist accordingly
  (cond ( (< x y) (executeSublist (car toExecute)))
	( (> x y) (executeSublist (car (cdr toExecute))))
	( (= x y) (executeSublist (car (cdr (cdr toExecute)))))
  )
  )
)
