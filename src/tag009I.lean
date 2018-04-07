-- here we define a presheaf of types on a basis of a top space;
-- sections only defined on a basis
-- restriction maps are just from basis elt to basis elt
-- 

import analysis.topology.topological_space

structure presheaf_of_types_on_basis {X : Type*} [TX : topological_space X] {B : set (set X)}
  (HB : topological_space.is_topological_basis B) := 
(F : Π {U : set X}, B U → Type*)
(res : ∀ {U V : set X} (BU : B U) (BV : B V) (H : V ⊆ U), 
  (F BU) → (F BV))
(Hid : ∀ (U : set X) (BU : B U), (res BU BU (set.subset.refl U)) = id)  
(Hcomp : ∀ (U V W : set X) (BU : B U) (BV : B V) (BW : B W)
  (HUV : V ⊆ U) (HVW : W ⊆ V),
  (res BU BW (set.subset.trans HVW HUV)) = (res BV BW HVW) ∘ (res BU BV HUV) )


structure morphism_of_presheaves_of_types_on_basis {X : Type*} [TX : topological_space X] 
  {B : set (set X)} {HB : topological_space.is_topological_basis B}
  (FPT : presheaf_of_types_on_basis HB) 
  (GPT : presheaf_of_types_on_basis HB) 
  :=
(morphism : ∀ U : set X, ∀ HU : B U, (FPT.F HU) → GPT.F HU)
(commutes : ∀ U V : set X, ∀ HU : B U, ∀ HV : B V, ∀ Hsub : V ⊆ U,
  (GPT.res HU HV Hsub) ∘ (morphism U HU) = (morphism V HV) ∘ (FPT.res HU HV Hsub))

definition composition_of_morphism_of_presheaves_of_types_on_basis
{X : Type*} [TX : topological_space X] 
  {B : set (set X)} {HB : topological_space.is_topological_basis B}
  {FPT : presheaf_of_types_on_basis HB} 
  {GPT : presheaf_of_types_on_basis HB} 
  {HPT : presheaf_of_types_on_basis HB}
  (phi : morphism_of_presheaves_of_types_on_basis FPT GPT)
  (psi : morphism_of_presheaves_of_types_on_basis GPT HPT)
  : morphism_of_presheaves_of_types_on_basis FPT HPT :=
{
  morphism := λ U HU, (psi.morphism U HU) ∘ (phi.morphism U HU),
  commutes := λ U V HU HV Hsub, --by simp [psi.commutes U V HU HV Hsub,phi.commutes U V HU HV Hsub]
  by rw [←function.comp.assoc,psi.commutes,function.comp.assoc,phi.commutes],
}

definition is_identity_morphism_of_presheaves_of_types_on_basis {X : Type*} [TX : topological_space X] 
  {B : set (set X)} {HB : topological_space.is_topological_basis B}
  {FPT : presheaf_of_types_on_basis HB} (phi : morphism_of_presheaves_of_types_on_basis FPT FPT)
  : Prop :=
  ∀ U : set X, ∀ HU : B U, phi.morphism U HU = id 

definition is_isomorphism_of_presheaves_of_types_on_basis 
{X : Type*} [TX : topological_space X] 
  {B : set (set X)} {HB : topological_space.is_topological_basis B}
  {FPT : presheaf_of_types_on_basis HB}
  {GPT : presheaf_of_types_on_basis HB}
  (phi : morphism_of_presheaves_of_types_on_basis FPT GPT) : Prop := 
  ∃ psi :  morphism_of_presheaves_of_types_on_basis GPT FPT,
  is_identity_morphism_of_presheaves_of_types_on_basis (composition_of_morphism_of_presheaves_of_types_on_basis phi psi)
  ∧ is_identity_morphism_of_presheaves_of_types_on_basis (composition_of_morphism_of_presheaves_of_types_on_basis psi phi)

  