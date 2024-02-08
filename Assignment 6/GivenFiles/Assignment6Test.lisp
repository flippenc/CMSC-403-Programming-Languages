(load "Assignment6.lisp")

(defun doesFunctionExist (funcName)
	(handler-case (funcall (intern (string-upcase funcName))) 
		(UNDEFINED-FUNCTION () (format t "FAIL: ~a is not defined~%" funcName) (RETURN-FROM doesFunctionExist NIL))
		(T () T) 
	)
	T
)

(defun doesMacroExist (macroName)
	(locally
		(declare (sb-ext:muffle-conditions cl:warning))
			(if (macro-function (intern (string-upcase macroName)))
				;True Branch
				T
				;false branch
				(progn (format t "FAIL: ~a is not defined~%" macroName) NIL)
			)    	
    )
)

;NOTE: This function handles all exception handling for user defined functions. (Not Macros) 
;If the resulting error string is not NIL, the corespinding test will not be run at all 
(defun getErrorString (f &rest a)
	(handler-case
		(progn (apply f a) NIL)
	(error (e)				
		(remove #\linefeed (format NIL "Got an exception: ~a"  e) )
	)
	)
)

(defun unbindFunctions () 
	(fmakunbound 'myList)
	(fmakunbound 'leapYear)
	(fmakunbound 'union-)
	(fmakunbound 'avg)
	(fmakunbound 'isType)
	(fmakunbound 'taxCalculator)
	(fmakunbound 'clean)
	(fmakunbound 'threeWayBranch)
)

(format t "~%myList Tests~%")
(if (doesFunctionExist "myList")
	(let* 
		((actual 
			(handler-case
				(myList)
			(error (e)
				(remove #\linefeed (format NIL "Got an exception: ~a"  e) )
				)
			)
		) 
		(expected (list 4 (list 7 22) "art" (list "math" (list 8) 99) 100))
		(result (equal actual expected)))


		 


		(if (not (NULL result))
			 (format t "PASS: List is built correctly~%") 
			 (format t "FAIL: ~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
		)
	)
)

(format t "~%leapYear Tests~%") 
(if (doesFunctionExist "leapYear")
	(let (
		(actual 
			(handler-case
				(leapYear)
			(error ()
				'(())
			)
			)
		) 

		(expected '(1804 1808 1812 1816 1820 1824 1828 1832 1836 1840 1844 1848 1852 1856 1860
	 1864 1868 1872 1876 1880 1884 1888 1892 1896 1904 1908 1912 1916 1920 1924
	 1928 1932 1936 1940 1944 1948 1952 1956 1960 1964 1968 1972 1976 1980 1984
	 1988 1992 1996 2000 2004 2008 2012 2016 2020))

		(isError 
			(handler-case
				(progn (leapYear) NIL)
			(error (e)				
				(remove #\linefeed (format NIL "Got an exception: ~a"  e) )
			)
			)
		)

		)

		(if (NULL isError)
			;If we do not have an exception
			(let ()
				;Test if we have all the expected leap years
				(let ((result ()))

					(dolist (x expected) (if (find x actual) () (push x result)))

					(if (NULL result)
					 (format t "PASS: Have all leap years~%") 
					 (format t "FAIL: Missing leap years: ~a~%" result)
					)

				)
				;Test if we have any years that are not leap years 
				(let ((result ()))

					(dolist (x actual) (if (find x expected) () (push x result)))

					(if (NULL result)
					 (format t "PASS: Only has leap years~%") 
					 (format t "FAIL: The following are not leap years: ~a~%" result)
					)

				)
			)
			;If we do have an exception, print out the expected number of FAIL lines with the exception generated
			(let ()
				(progn
					(format t "FAIL: ~a~%" isError)
					(format t "FAIL: ~a~%" isError)
				)
			)
		)


	)
)

(format t "~%union- Tests~%")
(if (doesFunctionExist "union-")
	(let ( 
		   (isErrorExclusive (getErrorString #'union- '(1 2 3 4 5) '(6 7 8 9 10) ) ) 
		   (isErrorIdentical (getErrorString #'union- '(1 2 3 4 5) '(5 4 3 2 1) ) )
		   (isErrorOverlapping (getErrorString #'union- '(1 2 3 6 7) '(7 6 8 9 10) ) )
		   (isErrorOneNIL (getErrorString #'union- '(1 2 3 9 10) () ) )
		   (isErrorBothNIL (getErrorString #'union- () () ) )
		   (isErrorNonNumeric (getErrorString #'union- '(2 3 X Y Z) '(1 2 3 A B C X Y) ) )

		 )
		
		;Exclusive lists 
		(if (NULL isErrorExclusive)
			;If we do not have an exception
			(let* 
				((actual (union- '(1 2 3 4 5) '(6 7 8 9 10))) 
				(expected '(1 2 3 4 5 6 7 8 9 10))
				;set-exclusive-or tests if actual and expected have the same elements
				(correctElements (NULL (set-exclusive-or actual expected)))
				;Check that there are no duplicates in actual by calling remove-duplicates on actual and comparing it to actual 
				(noDuplicates (equal actual (remove-duplicates actual)))
				;And the two booleans together to determine if the test passes or fails 
				(result (AND correctElements noDuplicates)))


				(if (not (NULL result))
					 (format t "PASS: all difference elements~%") 
					 (format t "FAIL: all difference elements~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorExclusive)
			)
		)

		;Identical lists 
		(if (NULL isErrorIdentical)
			(let* 
				((actual (union- '(1 2 3 4 5) '(5 4 3 2 1))) 
				(expected '(1 2 3 4 5))
				;set-exclusive-or tests if actual and expected have the same elements
				(correctElements (NULL (set-exclusive-or actual expected)))
				;Check that there are no duplicates in actual by calling remove-duplicates on actual and comparing it to actual 
				(noDuplicates (equal actual (remove-duplicates actual)))
				;And the two booleans together to determine if the test passes or fails 
				(result (AND correctElements noDuplicates)))


				(if (not (NULL result))
					 (format t "PASS: identical lists~%") 
					 (format t "FAIL: identical lists~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorIdentical)
			)
		)

		;Overlapping lists 
		(if (NULL isErrorOverlapping)
			(let* 
				((actual (union- '(1 2 3 6 7) '(7 6 8 9 10))) 
				(expected '(1 2 3 6 7 8 9 10))
				;set-exclusive-or tests if actual and expected have the same elements
				(correctElements (NULL (set-exclusive-or actual expected)))
				;Check that there are no duplicates in actual by calling remove-duplicates on actual and comparing it to actual 
				(noDuplicates (equal actual (remove-duplicates actual)))
				;And the two booleans together to determine if the test passes or fails 
				(result (AND correctElements noDuplicates)))


				(if (not (NULL result))
					 (format t "PASS: overlapping lists~%") 
					 (format t "FAIL: overlapping lists~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorOverlapping)
			)
		)

		;One NIL list
		(if (NULL isErrorOneNIL) 
			(let* 
				((actual (union- '(1 2 3 9 10) ())) 
				(expected '(1 2 3 9 10))
				;set-exclusive-or tests if actual and expected have the same elements
				(correctElements (NULL (set-exclusive-or actual expected)))
				;Check that there are no duplicates in actual by calling remove-duplicates on actual and comparing it to actual 
				(noDuplicates (equal actual (remove-duplicates actual)))
				;And the two booleans together to determine if the test passes or fails 
				(result (AND correctElements noDuplicates)))


				(if (not (NULL result))
					 (format t "PASS: one NIL list~%") 
					 (format t "FAIL: one NIL list~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			(let ()
				(format t "FAIL: ~a~%" isErrorOneNIL)
			)
		)

		;Both NIL lists
		(if (NULL isErrorBothNIL)
			(let* 
				((actual (union- () ())) 
				(expected ())
				;set-exclusive-or tests if actual and expected have the same elements
				(correctElements (NULL (set-exclusive-or actual expected)))
				;Check that there are no duplicates in actual by calling remove-duplicates on actual and comparing it to actual 
				(noDuplicates (equal actual (remove-duplicates actual)))
				;And the two booleans together to determine if the test passes or fails 
				(result (AND correctElements noDuplicates)))


				(if (not (NULL result))
					 (format t "PASS: Both NIL lists~%") 
					 (format t "FAIL: Both NIL lists~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorBothNIL)
			)
		)

		;Non numeric lists
		(if (NULL isErrorNonNumeric)
			(let* 
				((actual (union- '(2 3 X Y Z) '(1 2 3 A B C X Y))) 
				(expected '(1 2 3 A C B X Y Z))
				;set-exclusive-or tests if actual and expected have the same elements
				(correctElements (NULL (set-exclusive-or actual expected)))
				;Check that there are no duplicates in actual by calling remove-duplicates on actual and comparing it to actual 
				(noDuplicates (equal actual (remove-duplicates actual)))
				;And the two booleans together to determine if the test passes or fails 
				(result (AND correctElements noDuplicates)))


				(if (not (NULL result))
					 (format t "PASS: Non numeric lists~%") 
					 (format t "FAIL: Non numeric lists~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorNonNumeric)
			)
		)
	)
)
;;TODO make a test for a NIL input
(format t "~%avg Tests~%")
(if (doesFunctionExist "avg")
	(let (
			(isErrorOneElementList (getErrorString #'avg '(1) ) )
			(isErrorAvgWholeNumber (getErrorString #'avg '(2 5 3 10) ) )
			(isErrorAvgFractionNumber (getErrorString #'avg '(20 1 63 163 1/5 10/6 97 35) ) )
			(isErrorNilList (getErrorString #'avg () ) )
		)
		;List with one element
		(if (NULL isErrorOneElementList)
			;If we do not have an exception
			(let* 
				((actual (avg '(1))) 
				(expected 1)
				(result (equal actual expected)))

				(if (not (NULL result))
					 (format t "PASS: List with one element~%") 
					 (format t "FAIL: List with one element~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorOneElementList)
			)
		)

		;Avg is whole number
		(if (NULL isErrorAvgWholeNumber)
			;If we do not have an exception
			(let* 
				((actual (avg '(2 5 3 10)) )
				(expected 5)
				(result (equal actual expected)))


				(if (not (NULL result))
					 (format t "PASS: Avg is whole number~%") 
					 (format t "FAIL: Avg is whole number~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorAvgWholeNumber)
			)
		)

		;Avg is fraction 
		(if (NULL isErrorAvgFractionNumber)
			;If we do not have an exception
			(let* 
				((actual (avg '(20 1 63 163 1/5 10/6 97 35)) )
				(expected 5713/120)
				(result (equal actual expected)))

				(if (not (NULL result))
					 (format t "PASS: Avg is fraction ~%") 
					 (format t "FAIL: Avg is fraction ~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorAvgFractionNumber)
			)
		)

		;Empty list
		(if (NULL isErrorNilList)
			;If we do not have an exception
			(let* 
				((actual (avg '())) 
				(expected ())
				(result (equal actual expected)))

				(if (not (NULL result))
					 (format t "PASS: Empty list ~%") 
					 (format t "FAIL: Empty list ~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorNilList)
			)
		)
	)
)

(format t "~%isType Tests~%")
(if (doesFunctionExist "isType")
	(let (
			;Ugly solution which checks if isType throws an exception and if not, see if the returned function throws an exception
			;If isType does throw an exception, NIL is passed to the outer call of getErrorString
			(isErrorReturnFunction (getErrorString #'isType 'String) )
			(isErrorStringToString (getErrorString (if (NULL (getErrorString #'isType 'String) ) (isType 'String) () ) "String") )
			(isErrorStringToList   (getErrorString (if (NULL (getErrorString #'isType 'String) ) (isType 'String) () ) '(3 4 2)) )
			(isErrorNumberToNumber (getErrorString (if (NULL (getErrorString #'isType 'Number) ) (isType 'Number) () )      4/5) )
			(isErrorNumberToList   (getErrorString (if (NULL (getErrorString #'isType 'Number) ) (isType 'Number) () ) '(3 4 2)) )
		)
		;isType returns a function
		(if (NULL isErrorReturnFunction)
			;If we do not have an exception
			(let* 
				((actual (functionp (isType 'String))) 
				(expected T)
				(result (AND actual expected)))

				(if (not (NULL result))
					 (format t "PASS: isType returns a function~%") 
					 (format t "FAIL: Expected isType to return a function but returned: ~a~%" (remove #\linefeed (format NIL "~a" (isType 'String))) )

				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorReturnFunction)
			)
		)

		;Anonymous function bound to 'String given String
		(if (NULL isErrorStringToString)
			;If we do not have an exception
			(let* 
				((actual (funcall (isType 'String) "String")) 
				(expected T)
				(result (AND actual expected)))




				(if (not (NULL result))
					 (format t "PASS: isType passed a 'String argument, returned anonymous function passed a String~%") 
					 (format t "FAIL: isType passed a 'String argument, expected the returned anonymous function to return T when passed a String~%")
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorStringToString)
			)
		)

		;Anonymous function bound to 'String given list
		(if (NULL isErrorStringToList)
			;If we do not have an exception
			(let* 
				((actual (funcall (isType 'String) '(3 4 2)))  
				(expected NIL)
				;NIL AND NIL make nil so to test that actual and expected are both NIL we invert them to T then do the AND operation
				(result (AND (NOT actual) (NOT expected))))

				(if (not (NULL result))
					 (format t "PASS: isType passed a 'String argument, returned anonymous function passed a list~%") 
					 (format t "FAIL: isType passed a 'String argument, expected the returned anonymous function to return NIL when passed a list~%")
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorStringToList)
			)
		)

		;Anonymous function bound to 'Number given Number
		(if (NULL isErrorNumberToNumber)
			;If we do not have an exception
			(let* 
				((actual (funcall (isType 'Number) 4/5))  
				(expected T)
				(result (AND actual expected)))


				(if (not (NULL result))
					 (format t "PASS: isType passed a 'Number argument, returned anonymous function passed a number~%") 
					 (format t "FAIL: isType passed a 'Number argument, expected the returned anonymous function to return T when passed a number~%")
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorNumberToNumber)
			)
		)

		;Anonymous function bound to 'Number given list
		(if (NULL isErrorNumberToList)
			;If we do not have an exception
			(let* 
				((actual (funcall (isType 'Number) '(3 4 2))) 
				(expected NIL)
				;NIL AND NIL make nil so to test that actual and expected are both NIL we invert them to T then do the AND operation
				(result (AND (NOT actual) (NOT expected))))


				(if (not (NULL result))
					 (format t "PASS: isType passed a 'Number argument, returned anonymous function passed a list~%") 
					 (format t "FAIL: isType passed a 'Number argument, expected the returned anonymous function to return NIL when passed a list~%")
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorNumberToList)
			)
		)
	)
)

(format t "~%taxCalculator Tests~%")
(if (doesFunctionExist "taxCalculator")
	(let (
			(isErrorNone>Limit (getErrorString #'taxCalculator 100 1/2 '(1 99 24 12 64 52 91 38 10 2 4 6) ) )
			(isErrorSome>Limit (getErrorString #'taxCalculator 50  1/2 '(1 99 24 12 64 52 91 38 10 2 4 6) ) )
			(isErrorAll>Limit (getErrorString #'taxCalculator 20 2/3 '(100/2 99 24 122 64 52 91 38 70 246) ) )
			(isErrorValuesEmptyList (getErrorString #'taxCalculator 50 0 '() ) )
		)
		;No elements greater than limit
		(if (NULL isErrorNone>Limit)
			;If we do not have an exception 
			(let* 
				((actual (taxCalculator 100 1/2 '(1 99 24 12 64 52 91 38 10 2 4 6))) 
				(expected '(1 99 24 12 64 52 91 38 10 2 4 6))
				(result (equal actual expected)))

				(if (not (NULL result))
					 (format t "PASS: No elements greater than limit~%") 
					 (format t "FAIL: No elements greater than limit~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorNone>Limit)
			)
		)

		;Some elements greater than limit 
		(if (NULL isErrorSome>Limit)
			;If we do not have an exception 
			(let* 
				((actual (taxCalculator 50 1/2 '(1 99 24 12 64 52 91 38 10 2 4 6)))
				(expected '(1 99/2 24 12 32 26 91/2 38 10 2 4 6))
				(result (equal actual expected)))

				(if (not (NULL result))
					 (format t "PASS: Some elements greater than limit~%") 
					 (format t "FAIL: Some elements greater than limit~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorSome>Limit)
			)
		)

		;All elements greater than limit 
		(if (NULL isErrorAll>Limit)
			;If we do not have an exception 
			(let* 
				((actual (taxCalculator 20 2/3 '(100/2 99 24 122 64 52 91 38 70 246)))
				(expected '(100/3 66 16 244/3 128/3 104/3 182/3 76/3 140/3 164))
				(result (equal actual expected)))


				(if (not (NULL result))
					 (format t "PASS: All elements greater than limit~%") 
					 (format t "FAIL: All elements greater than limit~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorAll>Limit)
			)
		)

		;Values is an empty list 
		(if (NULL isErrorValuesEmptyList)
			;If we do not have an exception 
			(let* 
				((actual (taxCalculator 50 0 '()) ) 
				(expected NIL)
				;NIL AND NIL make nil so to test that actual and expected are both NIL we invert them to T then do the AND operation
				(result (AND (NOT actual) (NOT expected))))

				(if (not (NULL result))
					 (format t "PASS: Values is an empty list~%") 
					 (format t "FAIL: Values is an empty list~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorValuesEmptyList)
			)
		)
	)
)

(format t "~%clean Tests~%")
(if (doesFunctionExist "clean")
	(let*(
	   		(stringTest (lambda (value) (typep value 'String)))
	   		(numberTest (lambda (value) (typep value 'Number)))
	   		(charTest (lambda (value) (typep value 'Character)))

	   		(isErrorSingleListNoRemove (getErrorString #'clean numberTest '(1 2 3 4 5 6 7) ) )
			(isErrorSingleListAllRemove (getErrorString #'clean stringTest '(1 2 3 4 5 6 7) ) )
			(isErrorSingleListSomeRemove (getErrorString #'clean charTest '(1 #\x 3 #\y 5 "Jello" 7 #\z) ) )
			(isErrorNestedListNoRemove (getErrorString #'clean numberTest '(1 (2 3) 4 (5 6 7)) ) )
			(isErrorNestedListAllRemove (getErrorString #'clean stringTest '(1 (2 3) 4 (5 6 7)) ) )
			(isErrorNestedListSomeRemove (getErrorString #'clean charTest '(1 (#\x 3) #\y 5 ("Jello" 7 #\z)) ) )
			(isErrorNestedListAllRemoveSublist (getErrorString #'clean stringTest '("Hello" (2 3 4 5 6 7) "World") ) )
			(isErrorMultiNestedListNoRemove (getErrorString #'clean numberTest '(1 (2 (18 19 (-1 -2 -3) 20) 3) 4 (5 6 7)) ) )
			(isErrorMultiNestedListSomeRemove (getErrorString #'clean charTest '(1 (#\c (#\b #\a (-1 #\x -3) 20) #\y) "4" (5 #\z 7)) ) )

	   	)
		;Single list nothing to remove 
		(if (NULL isErrorSingleListNoRemove)
			;If we do not have an exception 
			(let* 
				((actual (clean numberTest '(1 2 3 4 5 6 7))) 
				(expected '(1 2 3 4 5 6 7))
				(result (equal actual expected)))

				(if (not (NULL result))
					 (format t "PASS: Single list nothing to remove~%") 
					 (format t "FAIL: Single list nothing to remove~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorSingleListNoRemove)
			)
		)

		;Single list remove all elements 
		(if (NULL isErrorSingleListAllRemove)
			;If we do not have an exception 
			(let* 
				((actual (clean stringTest '(1 2 3 4 5 6 7))) 
				(expected ())
				;NIL AND NIL make nil so to test that actual and expected are both NIL we invert them to T then do the AND operation
				(result (AND (NOT actual) (NOT expected))))

				(if (not (NULL result))
					 (format t "PASS: Single list remove all elements~%") 
					 (format t "FAIL: Single list remove all elements~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorSingleListAllRemove)
			)
		)

		;Single list remove some things
		(if (NULL isErrorSingleListSomeRemove)
			;If we do not have an exception 
			(let* 
				((actual (clean charTest '(1 #\x 3 #\y 5 "Jello" 7 #\z))) 
				(expected '(#\x #\y #\z))
				(result (equal actual expected)))

				(if (not (NULL result))
					 (format t "PASS: Single list remove some things~%") 
					 (format t "FAIL: Single list remove some things~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorSingleListSomeRemove)
			)
		)

		;Nested list nothing to remove 
		(if (NULL isErrorNestedListNoRemove)
			;If we do not have an exception 
			(let* 
				((actual (clean numberTest '(1 (2 3) 4 (5 6 7))))
				(expected '(1 (2 3) 4 (5 6 7)))
				(result (equal actual expected)))

				(if (not (NULL result))
					 (format t "PASS: Nested list nothing to remove~%") 
					 (format t "FAIL: Nested list nothing to remove~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorNestedListNoRemove)
			)
		)

		;Nested list remove all elements 
		(if (NULL isErrorNestedListAllRemove)
			;If we do not have an exception 
			(let* 
				((actual (clean stringTest '(1 (2 3) 4 (5 6 7))))
				(expected '(() ()))
				;NIL AND NIL make nil so to test that actual and expected are both NIL we invert them to T then do the AND operation
				(result (equal actual expected)))

				(if (not (NULL result))
					 (format t "PASS: Nested list remove all elements~%") 
					 (format t "FAIL: Nested list remove all elements~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorNestedListAllRemove)
			)
		)

		;Nested list remove some things
		(if (NULL isErrorNestedListSomeRemove)
			;If we do not have an exception 
			(let* 
				((actual (clean charTest '(1 (#\x 3) #\y 5 ("Jello" 7 #\z))))
				(expected '((#\x) #\y (#\z)))
				(result (equal actual expected)))

				(if (not (NULL result))
					 (format t "PASS: Nested list remove some things~%") 
					 (format t "FAIL: Nested list remove some things~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorNestedListSomeRemove)
			)
		)

		;Nested list remove all elements of sublist 
		(if (NULL isErrorNestedListAllRemoveSublist)
			;If we do not have an exception  
			(let* 
				((actual (clean stringTest '("Hello" (2 3 4 5 6 7) "World")))
				(expected '("Hello" () "World"))
				;NIL AND NIL make nil so to test that actual and expected are both NIL we invert them to T then do the AND operation
				(result (equal actual expected)))

				(if (not (NULL result))
					 (format t "PASS: Nested list remove all elements of sublist~%") 
					 (format t "FAIL: Nested list remove all elements of sublist~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorNestedListAllRemoveSublist)
			)
		)

		;Multiple nested lists nothing to remove
		(if (NULL isErrorMultiNestedListNoRemove)
			;If we do not have an exception   
			(let* 
				((actual (clean numberTest '(1 (2 (18 19 (-1 -2 -3) 20) 3) 4 (5 6 7))))
				(expected '(1 (2 (18 19 (-1 -2 -3) 20) 3) 4 (5 6 7)))
				(result (equal actual expected)))

				(if (not (NULL result))
					 (format t "PASS: Multiple nested lists nothing to remove ~%") 
					 (format t "FAIL: Multiple nested lists nothing to remove ~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorMultiNestedListNoRemove)
			)
		)

		;Multiple nested lists remove some things
		(if (NULL isErrorMultiNestedListSomeRemove)
			;If we do not have an exception 
			(let* 
				((actual (clean charTest '(1 (#\c (#\b #\a (-1 #\x -3) 20) #\y) "4" (5 #\z 7))))
				(expected '((#\c (#\b #\a (#\x) ) #\y) (#\z)))
				(result (equal actual expected)))

				(if (not (NULL result))
					 (format t "PASS: Multiple nested lists remove some things ~%") 
					 (format t "FAIL: Multiple nested lists remove some things ~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorMultiNestedListSomeRemove)
			)
		)

	)
)


(format t "~%threeWayBranch Tests~%")
(if (doesMacroExist "threeWayBranch")
	(let*(
			(testVar NIL)
			(isErrorX<YSingle    (handler-case (progn (threeWayBranch 2 3 (   ((+ 10 2)) ((- 10 2)) ((* 3 3)) )) NIL) (error (e) (remove #\linefeed (format NIL "Got an exception: ~a"  e)))))
			(isErrorX>YSingle    (handler-case (progn (threeWayBranch 3 2 (   ((+ 10 2)) ((- 10 2)) ((* 3 3)) )) NIL) (error (e) (remove #\linefeed (format NIL "Got an exception: ~a"  e)))))
			(isErrorX=YSingle    (handler-case (progn (threeWayBranch 3 3 (   ((+ 10 2)) ((- 10 2)) ((* 3 3)) )) NIL) (error (e) (remove #\linefeed (format NIL "Got an exception: ~a"  e)))))
			(isErrorX<YMultiple  (handler-case (progn (threeWayBranch 2 3 ( ((setf testVar 10)(+ testVar 2)) ((setf testVar 2)(- 10 testVar)) ((setf testVar 3)(* testVar testVar)))) NIL) (error (e) (remove #\linefeed (format NIL "Got an exception: ~a"  e)))))
			(isErrorX>YMultiple  (handler-case (progn (threeWayBranch 2 3 ( ((setf testVar 10)(+ testVar 2)) ((setf testVar 2)(- 10 testVar)) ((setf testVar 3)(* testVar testVar)))) NIL) (error (e) (remove #\linefeed (format NIL "Got an exception: ~a"  e)))))
			(isErrorX=YMultiple  (handler-case (progn (threeWayBranch 2 3 ( ((setf testVar 10)(+ testVar 2)) ((setf testVar 2)(- 10 testVar)) ((setf testVar 3)(* testVar testVar)))) NIL) (error (e) (remove #\linefeed (format NIL "Got an exception: ~a"  e)))))
		)

		;(format t "Output: ~a ~a ~a ~a ~a ~a ~%" isErrorX<YSingle isErrorX>YSingle isErrorX=YSingle isErrorX<YMultiple isErrorX>YMultiple isErrorX=YMultiple)

		;x < y single statement 
		(if (NULL isErrorX<YSingle)
			;If we do not have an exception 
			(let* 
				((actual 
					(handler-case
						(threeWayBranch 2 3 (   ((+ 10 2)) ((- 10 2)) ((* 3 3)) ))
					(error ()
						35505)
					)
				 ) 
				(expected 12)
				(result 
					(handler-case
						(= actual expected)
					(error ()
						T)
					))
				)

				(if (not (NULL result))
					 (format t "PASS: x < y single statement~%") 
					 (format t "FAIL: x < y single statement~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorX<YSingle)
			)
		)

		;x > y single statement 
		(if (NULL isErrorX>YSingle)
			;If we do not have an exception 
			(let* 
				((actual 
					(handler-case
						(threeWayBranch 3 2 (   ((+ 10 2)) ((- 10 2)) ((* 3 3)) ))
					(error ()
						35505)
					)
				 ) 
				(expected 8)
						(result 
					(handler-case
						(= actual expected)
					(error ()
						T)
					))
				)

				(if (not (NULL result))
					 (format t "PASS: x > y single statement~%") 
					 (format t "FAIL: x > y single statement~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorX>YSingle)
			)
		)

		;x = y single statement
		(if (NULL isErrorX=YSingle)
			;If we do not have an exception  
			(let* 
				((actual 
					(handler-case
						(threeWayBranch 3 3 (   ((+ 10 2)) ((- 10 2)) ((* 3 3)) ))
					(error ()
						35505)
					)
				 ) 
				(expected 9)
						(result 
					(handler-case
						(= actual expected)
					(error ()
						T)
					))
				)

				(if (not (NULL result))
					 (format t "PASS: x = y single statement~%") 
					 (format t "FAIL: x = y single statement~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorX=YSingle)
			)
		)

		;x < y multiple statements
		(if (NULL isErrorX<YMultiple)
			;If we do not have an exception 
			(let* 
				((testVar NIL)
				(actual 
					(handler-case
						(threeWayBranch 2 3 ( ((setf testVar 10)(+ testVar 2)) ((setf testVar 2)(- 10 testVar)) ((setf testVar 3)(* testVar testVar))))
					(error ()
						35505)
					)
				)  
				(expected 12)
						(result 
					(handler-case
						(= actual expected)
					(error ()
						T)
					))
				)

				(if (not (NULL result))
					 (format t "PASS: x < y multiple statements~%") 
					 (format t "FAIL: x < y multiple statements~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorX<YMultiple)
			)
		)

		;x > y multiple statements
		(if (NULL isErrorX>YMultiple)
			;If we do not have an exception 
			(let* 
				((testVar NIL)
				(actual 
					(handler-case
						(threeWayBranch 3 2 ( ((setf testVar 10)(+ testVar 2)) ((setf testVar 2)(- 10 testVar)) ((setf testVar 3)(* testVar testVar))))
					(error ()
						35505)
					)
				)  
				(expected 8)
				(result 
					(handler-case
						(= actual expected)
					(error ()
						T)
					))
				)

				(if (not (NULL result))
					 (format t "PASS: x > y multiple statements~%") 
					 (format t "FAIL: x > y multiple statements~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorX>YMultiple)
			)
		)

		;x = y multiple statements
		(if (NULL isErrorX=YMultiple)
			;If we do not have an exception 
			(let* 
				((testVar NIL)
				(actual 
					(handler-case
						(threeWayBranch 3 3 ( ((setf testVar 10)(+ testVar 2)) ((setf testVar 2)(- 10 testVar)) ((setf testVar 3)(* testVar testVar))))
					(error ()
						35505)
					)
				) 
				(expected 9)
				(result 
					(handler-case
						(= actual expected)
					(error ()
						T)
					))
				)

				(if (not (NULL result))
					 (format t "PASS: x = y multiple statements~%") 
					 (format t "FAIL: x = y multiple statements~%	ACTUAL:   ~a~%	EXPECTED: ~a~%" actual expected)
				)
			)
			;If we do have an exception
			(let ()
				(format t "FAIL: ~a~%" isErrorX=YMultiple)
			)
		)
	)
)

(unbindFunctions)