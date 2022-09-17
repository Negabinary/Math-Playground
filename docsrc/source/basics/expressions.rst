Language Reference
========================

Functions
    In mathematical expressions, you can choose whether to call functions in a more functional-language style with :code:`f x y` or a more imperative-language style with :code:`f (x,y)`. This is because :code:`,` is syntactic sugar that compiles to :code:`)(`.

Sets
    Sets are represented using predicates. Instead of saying "x is in the set of natural numbers", we have an "is a natural number" predicate, :code:`Nat`, and then say that it applies to x, :code:`Nat x`.

Infix Notation
    There are three built-in infix operators, :code:`_ and _`, :code:`_ or _`, and :code:`_ = _`. All user-defined expressions are prefix, e.g. :code:`+ _ _`.

If
    If statements in this language are often called implication in other languages. When we write :code:`if P then Q`, we are saying that :code:`P` implies :code:`Q`, or whenever :code:`P` holds, :code:`Q` also holds.

Bi-Implication
    To denote :code:`(if P then Q) and (if Q then P)`, you can write `P = Q`. (There is no difference between equality and bi-implication in this language.)

Quantifiers
    There are two quantifiers in this language: :code:`forall _ . _` and :code:`exists _ . _`. ::

        forall A B . if A then if B then A

        exists x y. P(x,y)
    
    You can specify sets that the new identifiers belong to using :code:`:`: ::

        forall x y : Nat, a b : Bool, P. if P(x,a) then P(y,b)

Anonymous Functions
    Anonymous function (lambdas) are speficied using `fun _ . _`. Like quantifiers you can specify multiple identifiers, but unlike quantifiers you cannot specify that the arguments belong to a certain set. ::

        (fun x y. + 2 (+ x y)) (5,5) = 12

Negation
    The :code:`¬` symbol denotes negation. ::
    
        ¬ (3 = 4)

Set Shorthand
    In cases where it would be easier to read `n : Nat` can be written instead of `Nat n` to indicate set membership. Below some shorthands are shown, with their equivalents below: ::

        xs : List Nat
        List Nat xs
    
        f : Nat -> Nat -> Nat
        forall T. if Nat T then forall T'. if nat T' then Nat(f(T, T'))

        [] : forall x. List x
        forall x. List x []