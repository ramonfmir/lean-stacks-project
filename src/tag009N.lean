/-
\begin{lemma}
\label{lemma-extend-off-basis}
Let $X$ be a topological space.
Let $\mathcal{B}$ be a basis for the topology on $X$.
Let $\mathcal{F}$ be a sheaf of sets on $\mathcal{B}$.
There exists a unique sheaf of sets $\mathcal{F}^{ext}$
on $X$ such that $\mathcal{F}^{ext}(U) = \mathcal{F}(U)$
for all $U \in \mathcal{B}$ compatibly with the restriction
mappings.
\end{lemma}

\begin{proof}
We first construct a presheaf $\mathcal{F}^{ext}$ with the
desired property. Namely, for an arbitrary open $U \subset X$ we
define $\mathcal{F}^{ext}(U)$ as the set of elements
$(s_x)_{x \in U}$ such that $(*)$ of
Lemma \ref{lemma-condition-star-sections} holds.
It is clear that there are restriction mappings
that turn $\mathcal{F}^{ext}$ into a presheaf of sets.
Also, by Lemma \ref{lemma-condition-star-sections} we
see that $\mathcal{F}(U) = \mathcal{F}^{ext}(U)$
whenever $U$ is an element of the basis $\mathcal{B}$.
To see $\mathcal{F}^{ext}$ is a sheaf one may
argue as in the proof of Lemma \ref{lemma-sheafification-sheaf}.
\end{proof}
-/

-- sheaf on a basis = sheaf on the whole space

import analysis.topology.topological_space tag009J tag009H scheme 

theorem basis_element_is_open {X : Type*} [T : topological_space X]
 {B : set (set X)} (HB : topological_space.is_topological_basis B)
 {U : set X} (BU : B U) : T.is_open U := 
 begin
 have : T = topological_space.generate_from B := HB.2.2,
 rw this,
show topological_space.generate_open B U,
refine topological_space.generate_open.basic U BU,
end 

 definition restriction_of_presheaf_to_basis {X : Type*} [T : topological_space X]
 {B : set (set X)} {HB : topological_space.is_topological_basis B}
 (FP : presheaf_of_types X) : presheaf_of_types_on_basis HB :=
 { F := λ U BU, FP.F U (basis_element_is_open HB BU),
   res := λ {U V} BU BV H, FP.res U V (basis_element_is_open HB BU) (basis_element_is_open HB BV) H,
   Hid := λ U BU, FP.Hid U (basis_element_is_open HB BU),
   Hcomp := λ U V W BU BV BW,FP.Hcomp U V W (basis_element_is_open HB BU)
   (basis_element_is_open HB BV) (basis_element_is_open HB BW)
 }

definition extend_off_basis {X : Type*} [T : topological_space X] {B : set (set X)} 
  {HB : topological_space.is_topological_basis B} (FB : presheaf_of_types_on_basis HB)
  (HF : is_sheaf_of_types_on_basis FB)
  : presheaf_of_types X := 
  { F := λ U OU, { s : Π (x ∈ U), presheaf_on_basis_stalk FB x //
      -- s is locally a section -- condition (*) of tag 009M
      ∀ (x ∈ U), ∃ (V : set X) ( BV : V ∈ B) (Hx : x ∈ V) (sigma : FB.F BV), 
        ∀ (y ∈ U ∩ V), s y = λ _,⟦{U := V, BU := BV, Hx := H.2, s := sigma}⟧  
    },
    res := λ U W OU OW HWU ssub,⟨λ x HxW,(ssub.val x $ HWU HxW),
      λ x HxW,begin
        cases (ssub.property x (HWU HxW)) with V HV,
        cases HV with BV H2,
        cases H2 with HxV H3,
        cases H3 with sigma H4,
        existsi V, existsi BV, existsi HxV,existsi sigma,
        intros y Hy,
        rw (H4 y ⟨HWU Hy.1,Hy.2⟩)
      end⟩,
    Hid := λ U OU,funext (λ x,subtype.eq rfl),
    Hcomp := λ U V W OU OV OW HUV HVW,funext (λ x, subtype.eq rfl)
  }

--  #print subtype.mk_eq_mk -- this is a simp lemma so why can't
-- I use simp?

variables {X : Type*} [T : topological_space X] {B : set (set X)} 
  {HB : topological_space.is_topological_basis B} (FB : presheaf_of_types_on_basis HB)
  (HF : is_sheaf_of_types_on_basis FB)

--set_option pp.notation false 

theorem extension_is_sheaf {X : Type*} [T : topological_space X] {B : set (set X)} 
  {HB : topological_space.is_topological_basis B} (FB : presheaf_of_types_on_basis HB)
  (HF : is_sheaf_of_types_on_basis FB)
  : is_sheaf_of_types (extend_off_basis FB HF) := begin
  intros U OU γ Ui UiO Hcov,
  split,
  { intros b c Hbc,
    apply subtype.eq,
    apply funext,
    intro x,
    apply funext,
    intro HxU,
    rw ←Hcov at HxU,
    cases HxU with Uig HUig,
    cases HUig with H2 HUigx,
    cases H2 with g Hg,
    rw Hg at HUigx,
    -- Hbc is the assumption that b and c are locally equal.
    have Hig := congr_fun (subtype.mk_eq_mk.1 Hbc) g,
    have H := congr_fun (subtype.mk_eq_mk.1 Hig) x,
    --exact (congr_fun H HUigx),
    have H2 := congr_fun H HUigx,
    exact H2,
  },
  { intro s,
    existsi _,swap,
    { refine ⟨_,_⟩,
      { intros x HxU,
        rw ←Hcov at HxU,
        cases (classical.indefinite_description _ HxU) with Uig HUig,
        cases (classical.indefinite_description _ HUig) with H2 HUigx,
        cases (classical.indefinite_description _ H2) with g Hg,
        rw Hg at HUigx,
        have t := (s.val g),
        exact t.val x HUigx,
      },
      intros x HxU,
      rw ←Hcov at HxU,
      cases HxU with Uig HUig,
      cases HUig with H2 HUigx,
      cases H2 with g Hg,
      rw Hg at HUigx,
      cases (s.val g).property x HUigx with V HV,
      cases HV with BV H2,
      cases H2 with HxV H3,
      -- now replace V by W, in B, contained in V and in Uig, and containing x
      have OUig := UiO g,
      have H := ((topological_space.mem_nhds_of_is_topological_basis HB).1 _ :
        ∃ (W : set X) (H : W ∈ B), x ∈ W ∧ W ⊆ (V ∩ Ui g)),
        swap,
        have UVUig : T.is_open (V ∩ Ui g) := T.is_open_inter V (Ui g) _ OUig,
        have HxVUig : x ∈ V ∩ Ui g := ⟨_,HUigx⟩,
        exact mem_nhds_sets UVUig HxVUig,
        exact HxV,
        rw HB.2.2,
        exact topological_space.generate_open.basic V BV,
      cases H with W HW,
      cases HW with HWB H4,
      existsi W,
      existsi HWB,
      existsi H4.1,
      cases H3 with sigma Hsigma,
      existsi FB.res BV HWB (set.subset.trans H4.2 $ set.inter_subset_left _ _) sigma,
      intros y Hy,
      -- now apply Hsigma
      admit,

    },
    {
      admit
    }
  }
  end 
  #print filter.sets 
#print mem_nhds_sets 

--  #print topological_space.nhds 

  #print topological_space.is_topological_basis
#print topological_space.generate_from 
#print topological_space.generate_open





definition extend_off_basis_map {X : Type*} [T : topological_space X] {B : set (set X)} 
  {HB : topological_space.is_topological_basis B} (FB : presheaf_of_types_on_basis HB)
  (HF : is_sheaf_of_types_on_basis FB) :
  morphism_of_presheaves_of_types_on_basis FB (restriction_of_presheaf_to_basis (extend_off_basis FB HF)) := sorry

theorem extension_extends {X : Type*} [T : topological_space X] {B : set (set X)} 
  {HB : topological_space.is_topological_basis B} (FB : presheaf_of_types_on_basis HB)
  (HF : is_sheaf_of_types_on_basis FB) : 
  is_isomorphism_of_presheaves_of_types_on_basis (extend_off_basis_map FB HF) := sorry 

theorem extension_unique {X : Type*} [T : topological_space X] {B : set (set X)} 
  {HB : topological_space.is_topological_basis B} (FB : presheaf_of_types_on_basis HB)
  (HF : is_sheaf_of_types_on_basis FB) (G : presheaf_of_types X)
  (HG : is_sheaf_of_types G) (psi : morphism_of_presheaves_of_types_on_basis FB (restriction_of_presheaf_to_basis G))
  (HI : is_isomorphism_of_presheaves_of_types_on_basis psi) -- we have an extension which agrees with FB on B
  : ∃ rho : morphism_of_presheaves_of_types (extend_off_basis FB HF) G, -- I would happily change the direction of the iso rho
    is_isomorphism_of_presheaves_of_types rho ∧ 
    ∀ (U : set X) (BU : B U), 
      (rho.morphism U (basis_element_is_open HB BU)) ∘ ((extend_off_basis_map FB HF).morphism U BU) = (psi.morphism U BU) := sorry


