import analysis.topology.topological_space
import tag006N -- presheaf_of_rings
import tag0072 -- is_sheaf_of_rings
import tag0078 -- stalk
import tag007N -- stalks_of_presheaf_of_rings_on_basis_are_rings

universe u

-- A ringed space is a pair (X, O_X) where X is a topological space
-- and O_X is a sheaf of rings on X.

structure ringed_space (α : Type u) [X : topological_space α] :=
(O_X       : presheaf_of_rings α)
(O_X_sheaf : is_sheaf_of_rings O_X)

-- Approximation to two ringed spaces being isomorphic. The next step
-- is to define a morphism (f, f#) : (X, O_X) → (Y, O_Y) as a continuous
-- map f : X → Y and and f-map f# : O_X → O_Y of sheaves of rings. 

def ringed_spaces_isomorphic (α : Type u) [T : topological_space α] 
(X : ringed_space α) (Y : ringed_space α) : Prop :=
are_isomorphic_presheaves_of_rings (X.O_X) (Y.O_X)  

-- TODO: Define stalks_local.

def stalk_local
(α   : Type u) 
[X   : topological_space α]
(O_X : presheaf_of_types α)
(x   : α) : Prop :=
sorry 
--stalk O_X.to_presheaf_of_types x

--#check presheaf_of_rings_on_basis_stalk.stalks_of_presheaf_of_rings_on_basis_are_rings  

def stalks_local 
{α   : Type u} 
[X   : topological_space α] 
(O_X : presheaf_of_rings α) : Prop := 
∀ (x : α) (U : set α), 
is_open U → 
x ∈ U → 
stalk_local α O_X.to_presheaf_of_types x

-- A locally ringed space is a ringed space in which the stalks are local.

structure locally_ringed_space (α : Type u) [X : topological_space α] extends ringed_space α :=
(O_X_stalks_local : stalks_local O_X)

-- TODO: Prove that for X, Y locally ringed spaces, 
-- if f: X -> Y is an isomorphism of ringed spaces
-- then it is also an isomorphism of locally ringed
-- spaces.
