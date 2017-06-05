--- ----------------------------------------------------------------------------
--- This module provides some goodies and utility functions for SMTLib.
---
--- @author  Jan Tikovsky
--- @version May 2017
--- ----------------------------------------------------------------------------
module SMTLib.Goodies where

import FlatCurry.Types (VarIndex)

import SMTLib.Types

--- Transform a FlatCurry variable index into an SMTLib symbol
var2SMT :: VarIndex -> Symbol
var2SMT vi = 'x' : show (abs vi)

--- smart constructors for SMT terms

--- smart constructor for integer SMT terms
tint :: Int -> Term
tint = TConst . Num

--- smart constructor for floating point SMT terms
tfloat :: Float -> Term
tfloat = TConst . Dec

--- smart constructor for character SMT terms (represented as string)
tchar :: Char -> Term
tchar = TConst . Str . (: [])

--- smart constructor for variables
tvar :: VarIndex -> Term
tvar vi = tcomb (var2SMT vi) []

--- smart constructor for constructor terms
tcomb :: Ident -> [Term] -> Term
tcomb i ts = TComb (Id i) ts

--- smart constructor for qualified constructor terms
qtcomb :: Ident -> Sort -> [Term] -> Term
qtcomb i s ts = TComb (As i s) ts

--- smart constructors for SMT sorts

--- smart constructor for a sort representing type variables
tyVar :: Sort
tyVar = SComb "TVar" []

--- smart constructor for a sort representing a functional type
tyFun :: Sort
tyFun = SComb "Fun" []

--- smart constructor for sorts
tyComb :: Ident -> [Sort] -> Sort
tyComb i ss = SComb i ss

--- smart constructor for an equational SMT term
(=%) :: Term -> Term -> Term
t1 =% t2 = tcomb "=" [t1, t2]

--- smart constructor for an inequational SMT term
(/=%) :: Term -> Term -> Term
t1 /=% t2 = tcomb "not" [tcomb "=" [t1, t2]]

--- smart constructor for conjunctions of constraints
tand :: [Term] -> Term
tand = tcomb "and"

--- Constrain an SMT variable to be distinct from the given SMT terms
noneOf :: VarIndex -> [Term] -> Term
noneOf v cs = tand $ map (tvar v /=%) cs

--- Generate a `nop` command
nop :: Command
nop = Echo ""

--- Generate an `Assert` command for a given list of SMT terms
assert :: [Term] -> Command
assert ts = case ts of
  []  -> nop
  [t] -> Assert t
  _   -> Assert $ tand ts

--- Get the unqualified identifier of an `QIdent`
unqual :: QIdent -> Ident
unqual (Id   i) = i
unqual (As i _) = i
