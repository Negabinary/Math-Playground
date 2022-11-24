Top-Level Commands
============================

There are four command keywords, :code:`define`, :code:`assume`, :code:`show`, and :code:`import`. A new command begins whenever these keywords appear in the specification.

Define
------

The :code:`define` keyword creates new identifiers. Types, sets, predicates, propositions, functions and objects are all created the same way, and treated the same way by the prover. There's nothing to stop you compiling :code:`4(5)` (but good luck proving anything where :code:`4` is a function). ::

    define Bool
    define bool_and
    define bool_not

If you are definining a constructor, you can use :code:`define _ : _` to assume that the constructor belongs to some set. Note it would not be appropriate to define a function, such as `bool_and` with a set, because we would want to prove that it belongs to that set instead of assuming. ::

    define true : Bool
    define false : Bool

The above is shorthand for: ::

    define true 
    assume Bool(true)
    define false 
    assume Bool(false)

Finally there is also a :code:`define _ as _` constructor which allows you to define an identifier in terms of a mathematical expression. ::

    define bool_or x y as 
        bool_not(
            bool_and(
                bool_not(x), 
                bool_not(y)
            )
        )

The above is shorthand for: ::

    define bool_or
    assume forall x. forall y.
        bool_or(x, y) = bool_not(bool_and(bool_not(x), bool_not(y)))

Assume
------

The :code:`assume` keyword takes a mathematical statement and assumes it to be true, so that you can use it in proofs. ::

    assume bool_not true = false
    assume bool_not false = true
    assume forall x. if Bool x then x = true or x = false

Remember, it's my fault if a finished proof is wrong, but it's your fault if an assumption is wrong, so check your assumptions!

Show
------

The :code:`show` keyword takes a mathematical statement and allows you to prove it to be true. You can also use it as an assumption in later proofs. ::

    show forall x : Bool. bool_not (bool_not x) = x


Import
------

The :code:`import` keyword allows you to use all the definitions and assumptions in another file. ::

    import std.logic

The import name :code:`std.logic` refers to the file :code:`%AppData%/Godot/app_userdata/DiscMathPlayground/save/std/logic.mml` on Windows, or :code:`User://save/std/logic.mml` online.