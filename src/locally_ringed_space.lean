import analysis.topology.topological_space
import tag006N
import tag0072

universe u

-- TODO: Define stalks_local.

def stalks_local 
{α : Type u} 
[T : topological_space α] 
(O_X : presheaf_of_rings α) : Prop := sorry

-- TODO: Define sheaf_of_rings directly.

structure locally_ringed_space :=
(α : Type u)
(T : topological_space α)
(O_X : presheaf_of_rings α)
(O_X_sheaf : is_sheaf_of_rings O_X)
(O_X_stalks_local : stalks_local O_X)

-- TODO: Prove that for X, Y locally ringed spaces, 
-- if f: X -> Y is an isomorphism of ringed spaces
-- then it is also an isomorphism of locally ringed
-- spaces.
