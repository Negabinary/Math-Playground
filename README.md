# Math-Playground

What if the pen and paper you're writing your mathematical proof with could tell you that you've missed some cases?  
What if you didn't have to re-write most of the maths every time you want to write out another step of your proof?  
What if you could browse known maths like it was a programming library?  
What if checking someone else's proof was as easy as checking their assumptions?

Math-playground will be a user-friendly GUI proof assistant. The ultimate goal is that the assistant will be user-friendly enough for an A-Level student to use, but powerful enough to be able to do A-Level maths work, and prove its correctness along the way.

It differs from most current proof assistants because of this focus on user-friendliness, and trying to re-create the way we do maths on a computer, instead of turning maths into a programming language. It also differs from computer algebra systems because I have no intention to get the computer to write the proof for you, this is about the computer showing you what you *can* do not what you *should* do.

It is sadly not currently particularly user-friendly as it is very much a work in progress, nor is it particularly powerful, as there is a lot that remains to be implemented, though you are welcome to give it a go at https://negabinary.github.io/Math-Playground/.


# How to get started

Go to https://negabinary.github.io/Math-Playground/

An example proveable statement will be open at the bottom:

`For all (A, For all(B, For all(C,(A => B) => (B => C) => A => C)))`

In words: if (`A` implies `B`) and (`B` implies `C`), and A, then C.

You can begin by pressing 'Assume A then prove B'. You'll now see that our goal has changed to 'C', and we have some assumptions down the left.

Now you'll see that one of our assumptions down the left is 'If B then C'. Since we are trying to prove 'C', you can double click on the green 'C' to use this assumption.

Now our goal is 'B' and we can repeat.

Once all the orange `!`s are gone, the proof is complete.

## 2 + 2 = 4

Up the top left you will see some 'modules'. The first, called 'examples' gives some proofs for you to try. Right-click on the statement that says '+(2,2)' = '4'. (You will have to right-click on the '=', this is a bug, I will fix it, told you it was in progress)

Some useful things for doing this proof:

* The small_numbers module contains definitions of 2 and 4. (2 is the number after the number after 0.) You can use these definitions by clicking on a '2' at the bottom, then clicking on the yellow 'S(S(0))'

* The addition module contains the definition of addition over the natural numbers. These will be useful for this proof.

* If some step in the proof has an orange (!) next to it, that means that there is something in that step that hasn't been proven. Click on the step to the left of the (!) to view these.

* The type system is currently broken so you will have to convince it manually that all the types are correct. Hopefully in the future it will be able to prove `Nat(2)` (2 is a natural number) on its own. *I personally don't bother proving any of the type requirements at the moment. If you've proven it except for some `! Nat(x)`s, consider yourself done.*

* Note 0 is defined in the peano module, whereas 1-5 are defined in small_numbers

## 0 + n = 0

This almost sounds like it should be a definition, but it can be proven using 0 + n = 0.

This is a proof by induction, luckily proof by induction can be found at the bottom of the peano module.

* To use the proof by induction, we need to get `=(+(0,n),0)` in the form `P(m)`, which it is not currently. To do this we can select `=(+(0,n),0)`, then use the 'create lambda' button under 'More' in the 'JUSTIFICATION MISSING' box. By 'Replace: ' enter `n` then press enter. By 'with: ' give it a name that isn't n and don't press enter. (math-playground can cope fine with two variables with the same name, but you probably can't.) (I know that pressing enter for 'replace' and not for 'with' is inconsistent - again, it's a work in progress...)

* `>>(x,=(+(0,x),0),n)` is ugly notation, I know, I'll fix it eventually. What it means is `(x -> (0 + x = 0))(n)`

* Again the type system is still broken, so if you see a `! ->(...)` (which is asking you to prove the type of a function), ignore it, **you actually can't prove it yet, sorry**

# Can it prove anything yet?

Technically... If you want to use it as a 'Hilbert System' (i.e. you will have to define your own version of all the built-in identifiers within the environment (maybe `==>`, `forall` , `==`, `!`, and so on)) then it is complete!

However, there are a still a lot of features missing in order to prove anything in a more 'natural' way - and the random bugs and broken type system won't help you either...

# Brief Documentation

Expect this to go out of date quickly.

Spaces matter in most cases, never include a space unless it is part of the identifier name (e.g. `For all`). There are four reserved characters : `(`, `,`, `)`, `:`, everything else is part of an identifier. The comma might be misleading because in all cases `,` is treated as `)(`. `+(1,2)` = `+(1)(2)`.

### Built-in identifiers

* `=>(A,B)` sometimes appears `A => B` or `(A) => B` means if A then B.

  * To prove : use the 'A => B : Assume A then prove B' button

  * To use : => is automatically split up in assumptions, so `A => B` becomes 'if `A` then `B`' and you can double-click `B`

* `For all(A,B)` sometimes appears `@A A. B` means B holds for all values of A. (Binds A)

  * To prove : use the 'A => B : Assume A then prove B' button (yes, this button is badly named.)

  * To use : double-click on an identifier in the 'forall' section of an assumption. You can then type in any maths from the current context. **Warning : you must get the syntax right, no spaces unless in `For all`** (This will become a safer fancy editor soon.)

* `=(A,B)` sometimes appears `A = B` means A and B are equivalent in all contexts and can be substituted for each other.

  * To prove : use the 'A = A Prove using reflexivity' or 'F(A) = F(B) : Match Arguments' buttons.

  * To use : if you click on an instance of `A` in the goal, `B` should highlight yellow on the assumption, you can then double-click `B`.

* `¬(A)` means not A.

* `For some(A,B)` sometimes appears `@E A. B` means B holds for some value of A. (Binds A)

  * To prove : TODO

  * To use : If you click on the current goal, the assumption should go blue, and it can be double-clicked to instantiate.

* `>>(A,B(A))` sometimes appears `A -> B(A)` is a lambda construction that takes A and returns B. It can be applied with an extra argument, `>>(A,B(A),C)` = `B(C)`.

* `TAG(A)` is part of the dysfunctional type system, it means `A` is a type. `TAG` is itself a `TAG`, thus `TAG(TAG)`.

* `ANY(A)` is part of the dysfunctional type system, it means `A` could have any type.

* `PROP(A)` is part of the dysfunctional type system, it means `A` is a proposition, i.e. something that can be proved / disproved.

* `->(A,B)(C)` is part of the dysfunctional type system, it means `C` has type `A -> B`. For `(A,B) -> C` use `->(A,->(B,C))(D)`.

### Built-in modules

Some functionality is glaringly missing, for example, proof by cases, conjuction and disjunction. These are patiently waiting to become built-in identifiers and rules, but while they are waiting you can use the `logic` module.

Go to 'Add built-in module' at the top right, type `logic` into the box, and press ok.

Other modules:

* `typing` fixes some, but not all of the holes in the type system.

* `bool/bool_type`, `bool/bool_and`, and `bool/bool_or` contain some basic boolean facts, which you can try out by proving `bool/de_morgan`

* `real` contains some not-quite formalised real small_numbers. Note `/` in this module is a unary operator.

* `oddeven` contains definitions of Odd and Even numbers. The final theorem in this module, induction over the even numbers, can be proven, but it uses the newest and messiest features.



### Writing your own modules

I promise you I will make a better GUI for this as soon as possible.  If you do something interesting please tell me!

Two warnings: 1) **currently a syntax error will crash the program and you will lose your work** (remember: do not include unnecessary spaces!!) so 2) **make sure to copy out any modules that you write into somewhere more secure before you press ok.**

Add a name for the module in the top bar, then write the code for the module.

Each line in a module begins with two specific characters followed by a space, these are `@R`, `@D`, `@>`, `@A`, `@=` and `@<`.

`@R module_name` - This module now requires module_name, and can hence use all the identifiers defined in module_name.

`@D factorial` - This declares the identifier 'factorial'

`@D factorial : ->(Nat,Nat)` - This declares the identifier 'factorial' and gives it type 'Nat -> Nat'. (Recall, the type system is dysfunctional so you may struggle to prove things if you use this.)

`@> Even(+(2,2))` - adds the theorem 'two plus two is even' to the module. (must have `@R oddeven`, `@R addition` and `@R small_numbers` in the module.)

`@< A`  
`@< B`    
`@> C` - Shorthand for `=>(A,=>(B,C))`

`@A x`  
`@> P(x)` - Shorthand for `For all(x,P(x))`

`@= +(2,2)`  
`@> 4` - Shorthand for `=(+(2,2),4)`

Below is an example module: (which is the built-in library `trig`)

`trig`  
```
@R real

@D sin : ->(Real,Real)
@D cos : ->(Real,Real)
@D tan : ->(Real,Real)
@D cosec : ->(Real,Real)
@D sec : ->(Real,Real)
@D cot : ->(Real,Real)

@A x : Real
@= tan(x)
@> *(sin(x),/(cos(x)))

@A x : Real
@= cosec(x)
@> /(sin(x))

@A x : Real
@= sec(x)
@> /(cos(x))

@A x : Real
@= cot(x)
@> /(tan(x))

@A x : Real
@= +(*(sin(x),sin(x)),*(cos(x),cos(x)))
@> 1

@A x : Real
@< ¬(=(*(cos(x),cos(x)),0))
@= +(1,*(tan(x),tan(x)))
@> *(sec(x),sec(x))
```
