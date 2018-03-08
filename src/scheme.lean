import analysis.topology.topological_space data.set
import analysis.topology.continuity 
import Kenny_comm_alg.Zariski
import Kenny_comm_alg.temp
import tag00EJ_statement
import localization
import localization_UMP
import tag00E0
import tag00DY
import Kenny_comm_alg.temp

universes u v 
/-
structure ring_morphism {α : Type*} {β : Type*} (Ra : comm_ring α) (Rb : comm_ring β) (f : α → β) :=
(f_zero : f 0 = 0)
(f_one : f 1 = 1)
(f_add : ∀ {a₁ a₂ : α}, f (a₁ + a₂) = f a₁ + f a₂)
(f_mul : ∀ {a₁ a₂ : α}, f (a₁ * a₂) = f a₁ * f a₂) 
-/
local attribute [class] topological_space.is_open 

structure presheaf_of_types (α : Type*) [T : topological_space α] := 
(F : Π U : set α, T.is_open U → Type*)
(res : ∀ (U V : set α) (OU : T.is_open U) (OV : T.is_open V) (H : V ⊆ U), 
  (F U OU) → (F V OV))
(Hid : ∀ (U : set α) (OU : T.is_open U), (res U U OU _ (set.subset.refl U)) = id)  
(Hcomp : ∀ (U V W : set α) (OU : T.is_open U) (OV : T.is_open V) (OW : T.is_open W)
  (HUV : V ⊆ U) (HVW : W ⊆ V),
  (res U W OU OW (set.subset.trans HVW HUV)) = (res V W OV _ HVW) ∘ (res U V _ _ HUV) )

structure presheaf_of_rings (α : Type*) [T : topological_space α] extends presheaf_of_types α :=
(Fring : ∀ U OU, comm_ring (F U OU))
(res_is_ring_morphism : ∀ (U V : set α) (OU : T.is_open U) (OV : T.is_open V) (H : V ⊆ U),
  is_ring_hom (res U V OU OV H))
--attribute [class] presheaf_of_rings
--attribute [instance] presheaf_of_rings.Fring
--local attribute [instance] topological_space.is_open_inter

definition presheaf_of_types_pushforward
  {α : Type*} [Tα : topological_space α]
  {β : Type*} [Tβ : topological_space β]
  (f : α → β)
  (fcont: continuous f)
  (FPT : presheaf_of_types α) :
  presheaf_of_types β :=
{ F := λ V OV, FPT.F (f ⁻¹' V) (fcont V OV),
  res := λ V₁ V₂ OV₁ OV₂ H, 
    FPT.res (f ⁻¹' V₁) (f⁻¹' V₂) (fcont V₁ OV₁) (fcont V₂ OV₂) (λ x Hx,H Hx),
  Hid := λ V OV, FPT.Hid (f ⁻¹' V) (fcont V OV),
  Hcomp := λ Uβ Vβ Wβ OUβ OVβ OWβ HUV HVW,
    FPT.Hcomp (f ⁻¹' Uβ)(f ⁻¹' Vβ)(f ⁻¹' Wβ) (fcont Uβ OUβ) (fcont Vβ OVβ) (fcont Wβ OWβ)
    (λ x Hx, HUV Hx) (λ x Hx, HVW Hx) }

definition presheaf_of_rings_pushforward
  {α : Type*} [Tα : topological_space α]
  {β : Type*} [Tβ : topological_space β]
  (f : α → β)
  (fcont: continuous f)
  (FPR : presheaf_of_rings α) :
  presheaf_of_rings β :=
{ Fring := λ U OU,FPR.Fring (f ⁻¹' U) (fcont U OU),
  res_is_ring_morphism := λ U V OU OV H,
    FPR.res_is_ring_morphism (f ⁻¹' U) (f ⁻¹' V) (fcont U OU) (fcont V OV) (λ x Hx, H Hx),
  .. presheaf_of_types_pushforward f fcont FPR.to_presheaf_of_types }

structure open_immersion
  {α : Type*} [Tα : topological_space α]
  {β : Type*} [Tβ : topological_space β]
  (f : α → β) : Prop :=
(fcont : continuous f)
(finj : function.injective f)
(fopens : ∀ U : set α, is_open U ↔ is_open (f '' U))

--set_option pp.notation false 

lemma immersion_sends_opens_to_opens 
  {α : Type*} [Tα : topological_space α]
  {β : Type*} [Tβ : topological_space β]
  (f : α → β) (H : open_immersion f) : 
∀ U : set α, is_open U → is_open (f '' U) := λ U OU, (H.fopens U).1 OU

definition presheaf_of_types_pullback_under_open_immersion
  {α : Type*} [Tα : topological_space α]
  {β : Type*} [Tβ : topological_space β]
  (PT : presheaf_of_types β)
  (f : α → β)
  (H : open_immersion f) :
  presheaf_of_types α :=
{ F := λ U HU,PT.F (f '' U) ((H.fopens U).1 HU),
  res := λ U V OU OV H2,PT.res (f '' U) (f '' V) ((H.fopens U).1 OU) ((H.fopens V).1 OV)
    (set.image_subset f H2),
  Hid := λ _ _,PT.Hid _ _,
  Hcomp := λ U V W _ _ _ HUV HVW, 
    PT.Hcomp _ _ _ _ _ _ (set.image_subset f HUV) (set.image_subset f HVW) } 

definition presheaf_of_rings_pullback_under_open_immersion
  {α : Type*} [Tα : topological_space α]
  {β : Type*} [Tβ : topological_space β]
  (PR : presheaf_of_rings β)
  (f : α → β)
  (H : open_immersion f) :
  presheaf_of_rings α := 
{ Fring := λ U OU,PR.Fring (f '' U) (immersion_sends_opens_to_opens f H U OU),
  res_is_ring_morphism := λ U V OU OV H2,PR.res_is_ring_morphism (f '' U) (f '' V)
    (immersion_sends_opens_to_opens f H U OU)
    (immersion_sends_opens_to_opens f H V OV) 
    (set.image_subset f H2),
  .. presheaf_of_types_pullback_under_open_immersion PR.to_presheaf_of_types f H }

structure morphism_of_presheaves_of_types {α : Type*} [Tα : topological_space α] 
  (FPT : presheaf_of_types α) (GPT : presheaf_of_types α) :=
(morphism : ∀ U : set α, ∀ HU : Tα.is_open U, (FPT.F U HU) → GPT.F U HU)
(commutes : ∀ U V : set α, ∀ HU : Tα.is_open U, ∀ HV : Tα.is_open V, ∀ Hsub : V ⊆ U,
  (GPT.res U V HU HV Hsub) ∘ (morphism U HU) = (morphism V HV) ∘ (FPT.res U V HU HV Hsub))

structure morphism_of_presheaves_of_rings {α : Type*} [Tα : topological_space α]
  (FPR : presheaf_of_rings α) (GPR : presheaf_of_rings α) :=
(morphism : morphism_of_presheaves_of_types FPR.to_presheaf_of_types GPR.to_presheaf_of_types)
(ring_homs : ∀ U : set α, ∀ HU : is_open U, 
  @is_ring_hom _ _ (FPR.Fring U HU) (GPR.Fring U HU) (morphism.morphism U HU))

def composition_of_morphisms_of_presheaves_of_types {α : Type*} [Tα : topological_space α]
  {FPT GPT HPT : presheaf_of_types α} (fg : morphism_of_presheaves_of_types FPT GPT)
  (gh : morphism_of_presheaves_of_types GPT HPT) :
morphism_of_presheaves_of_types FPT HPT :=
{ morphism := λ U HU, gh.morphism U HU ∘ fg.morphism U HU,
  commutes := λ U V HU HV Hsub, begin
    show (HPT.res U V HU HV Hsub ∘ gh.morphism U HU) ∘ fg.morphism U HU =
    gh.morphism V HV ∘ (fg.morphism V HV ∘ FPT.res U V HU HV Hsub),
    rw gh.commutes U V HU HV Hsub,
    rw ←fg.commutes U V HU HV Hsub,
  end }

def identity_morphism_of_presheaves_of_types {α : Type*} [Tα : topological_space α]
  (FPT : presheaf_of_types α) : morphism_of_presheaves_of_types FPT FPT :=
{ morphism := λ _ _, id,
  commutes := λ _ _ _ _ _, rfl }

def are_isomorphic_presheaves_of_types {α : Type} [Tα : topological_space α]
(FPT : presheaf_of_types α) (GPT : presheaf_of_types α) : Prop :=
∃ (fg : morphism_of_presheaves_of_types FPT GPT) (gf : morphism_of_presheaves_of_types GPT FPT),
  composition_of_morphisms_of_presheaves_of_types fg gf = identity_morphism_of_presheaves_of_types FPT
  ∧ composition_of_morphisms_of_presheaves_of_types gf fg = identity_morphism_of_presheaves_of_types GPT

def are_isomorphic_presheaves_of_rings {α : Type} [Tα : topological_space α]
  (FPR : presheaf_of_rings α) (GPR : presheaf_of_rings α) : Prop := 
∃ (fg : morphism_of_presheaves_of_rings FPR GPR) (gf : morphism_of_presheaves_of_rings GPR FPR),
  composition_of_morphisms_of_presheaves_of_types fg.morphism gf.morphism = identity_morphism_of_presheaves_of_types FPR.to_presheaf_of_types
  ∧ composition_of_morphisms_of_presheaves_of_types gf.morphism fg.morphism = identity_morphism_of_presheaves_of_types GPR.to_presheaf_of_types


def res_to_inter_left {α : Type*} [T : topological_space α] 
  (FT : presheaf_of_types α)
  (U V : set α) [OU : T.is_open U] [OV : T.is_open V] :
  (FT.F U OU) → (FT.F (U ∩ V) (T.is_open_inter U V OU OV)) :=
FT.res U (U ∩ V) OU (T.is_open_inter U V OU OV) (set.inter_subset_left U V)

def res_to_inter_right {α : Type*} [T : topological_space α]
  (FT : presheaf_of_types α)
  (U V : set α) [OU : T.is_open U] [OV : T.is_open V] :
  (FT.F V OV) → (FT.F (U ∩ V) (T.is_open_inter U V OU OV)) :=
FT.res V (U ∩ V) OV (T.is_open_inter U V OU OV) (set.inter_subset_right U V)

def gluing {α : Type*} [T : topological_space α] (FP : presheaf_of_types α) 
  (U : set α)
  [UO : T.is_open U]
  {γ : Type*} (Ui : γ → set α)
  [UiO : ∀ i : γ, T.is_open (Ui i)]
  (Hcov : (⋃ (x : γ), (Ui x)) = U)
  (r : FP.F U UO) :
  {a : (Π (x : γ), (FP.F (Ui x) (UiO x))) | ∀ (x y : γ), 
    (res_to_inter_left FP (Ui x) (Ui y)) (a x) = 
    (res_to_inter_right FP (Ui x) (Ui y)) (a y)} :=
⟨λ x,(FP.res U (Ui x) UO (UiO x) (Hcov ▸ set.subset_Union Ui x) r),
 λ x₁ y₁, have Hopen : T.is_open ((Ui x₁) ∩ (Ui y₁)),
     from (T.is_open_inter _ _ (UiO x₁) (UiO y₁)),
   show ((FP.res (Ui x₁) ((Ui x₁) ∩ (Ui y₁)) _ Hopen _) ∘ (FP.res U (Ui x₁) _ _ _)) r =
        ((FP.res (Ui y₁) ((Ui x₁) ∩ (Ui y₁)) _ Hopen _) ∘ (FP.res U (Ui y₁) _ _ _)) r,
   by rw [← presheaf_of_types.Hcomp, ← presheaf_of_types.Hcomp]⟩

def is_sheaf_of_types {α : Type*} [T : topological_space α]
  (PT : presheaf_of_types α) : Prop :=
∀ (U : set α) [OU : T.is_open U] {γ : Type*} (Ui : γ → set α)
  [UiO : ∀ x : γ, T.is_open (Ui x)] (Hcov : (⋃ (x : γ), (Ui x)) = U),
function.bijective (@gluing _ _ PT U OU _ Ui UiO Hcov)

/-- This is OK because exactness is same for sheaves of rings and sets-/
def is_sheaf_of_rings {α : Type*} [T : topological_space α] 
  (PR : presheaf_of_rings α) : Prop :=
is_sheaf_of_types PR.to_presheaf_of_types

--theorem D_f_are_a_basis {R : Type u} [comm_ring R] : ∀ U : set (X R), topological_space.is_open (Zariski R) U → ∃ α : Type v, ∃ f : α → R, U = set.Union (Spec.D' ∘ f) := sorry

--definition structure_sheaf_on_union {R : Type u} [comm_ring R] {α : Type} (f : α → R) := 
--  {x : (Π i : α, localization.loc R (powers $ f i)) // ∀ j k : α, localise_more_left (f j) (f k) (x j) = localise_more_right (f j) (f k) (x k) } 

--#check topological_space.is_open 
--#check @localization.at_prime
-- #check @sheaf_of_rings 

/-
#print Spec.V'
#print is_ring_hom 
#check @localization.away.extend_map_of_im_unit
#check localization.of_comm_ring
#check @localization.prime.is_submonoid
#check @localization.unit_of_in_S
#check localization.away.extend_map_of_im_unit.is_ring_hom
-/

noncomputable definition canonical_map {R : Type*} [comm_ring R] (g : R) (u : X R) (H : u ∈ Spec.D' g) :
  localization.away g → @localization.at_prime R _ u.val u.property :=
@localization.away.extend_map_of_im_unit _ _ _ _
  (@localization.of_comm_ring R _ (set.compl u.val) (@localization.prime.is_submonoid _ _ u.val u.property))
  _
  g 
  (@localization.unit_of_in_S R _ (set.compl u.val) (@localization.prime.is_submonoid _ _ u.val u.property) ⟨g,H⟩)

instance canonical_map.is_ring_hom {R : Type*} [comm_ring R] (g : R) (u : X R) (H : u ∈ Spec.D' g) :
  is_ring_hom (canonical_map g u H) :=
localization.away.extend_map_of_im_unit.is_ring_hom _ _

theorem canonical_map.canonical_left {R : Type*} [comm_ring R] (g h : R) (Q : X R) (H : Q ∈ Spec.D' (g * h)) :
  ∀ x, canonical_map (g * h) Q H (localise_more_left g h x) = canonical_map g Q (mt (@@is_ideal.mul_right _ Q.2.1.1) H) x :=
congr_fun $ @@localization.away.extension_unique _ _
  (@@localization.of_comm_ring R _ (set.compl (Q.val)) (@canonical_map._proof_4 R _inst_1 Q)) _
  (canonical_map._proof_6 g Q (mt (@@is_ideal.mul_right _ Q.2.1.1) H))
  (localization.away.extend_map_of_im_unit (@@localization.of_comm_ring R _ (set.compl (Q.val)) (@canonical_map._proof_4 R _inst_1 Q))
     (canonical_map._proof_6 (g * h) Q H) ∘
     localise_more_left g h)
  (@@is_ring_hom.comp _ _ _ _ _ (localization.away.extend_map_of_im_unit.is_ring_hom _ _) (localization.away.extend_map_of_im_unit.is_ring_hom _ _))
  (λ r, by dsimp; simp [localise_more_left, localization.away.extend_map_extends])

theorem canonical_map.canonical_right {R : Type*} [comm_ring R] (g h : R) (Q : X R) (H : Q ∈ Spec.D' (g * h)) :
  ∀ x, canonical_map (g * h) Q H (localise_more_right g h x) = canonical_map h Q (mt (@@is_ideal.mul_left _ Q.2.1.1) H) x :=
congr_fun $ @@localization.away.extension_unique _ _
  (@@localization.of_comm_ring R _ (set.compl (Q.val)) (@canonical_map._proof_4 R _inst_1 Q)) _
  (canonical_map._proof_6 h Q (mt (@@is_ideal.mul_left _ Q.2.1.1) H))
  (localization.away.extend_map_of_im_unit (@@localization.of_comm_ring R _ (set.compl (Q.val)) (@canonical_map._proof_4 R _inst_1 Q))
     (canonical_map._proof_6 (g * h) Q H) ∘
     localise_more_right g h)
  (@@is_ring_hom.comp _ _ _ _ _ (localization.away.extend_map_of_im_unit.is_ring_hom _ _) (localization.away.extend_map_of_im_unit.is_ring_hom _ _))
  (λ r, by dsimp; simp [localise_more_right, localization.away.extend_map_extends])
 
local attribute [instance] localization.away.extend_map_of_im_unit.is_ring_hom

--set_option pp.notation false 
--set_option pp.proofs true
--set_option pp.implicit true
definition structure_presheaf_of_types_on_affine_scheme (R : Type*) [comm_ring R] : presheaf_of_types (X R) :=
{ F := λ U HU, { f : Π P : X R, P ∈ U → @localization.at_prime R _ P.val P.property // 
    ∀ u : X R, U u → ∃ g : R, u ∈ Spec.D' g ∧ Spec.D' g ⊆ U ∧ ∃ r : localization.away g, ∀ Q : X R, 
    Π HQQ : Q ∈ U, Π H2 : Q ∈ Spec.D' g, f Q HQQ = canonical_map g Q H2 r },
--λ U HU, { f : Π P : {u : X ∈ Spec.D' g ∧ Spec.D' g ⊆ U ∧ ∃ r : localization.away g, ∀ v : {v : X R // U v},
--  Π H2 : v.val ∈ Spec.D' g, f ⟨v.val,v.property⟩ = canonical_map g v H2 r }
  res := λ U V OU OV H f, ⟨λ P HP, f.val P (H HP), begin
    intros P HVP,
    -- P is in U, so existence of f says there exists g...
    rcases f.property P (H HVP) with ⟨g, Hg1, Hg2, r, Hr⟩,
    -- P is in V, so there exists h such that P in D(h) in V by 00E0(14)
    cases OV with T HT,
    rcases (tag00E0.cor_to_14 R T V HT P HVP) with ⟨h, Hh1, Hh2⟩,
    existsi (g*h),
    split,
    { -- proof that P is in D(gh)
      rw tag00E0.lemma15,
      exact ⟨Hg1, Hh1⟩ },
    have H4 : Spec.D' (g * h) ⊆ V,
    { -- proof that D(gh) is a sub of V
      rw tag00E0.lemma15,
      refine set.subset.trans _ Hh2,
      exact set.inter_subset_right _ _,
    },      
    split,
    { exact H4 },
    { -- r in R[1/g] but I need it in R[1/gh]
      existsi (localise_more_left g h r),
      intros Q HQ H2,
      -- Hr is the assertion that f is on both sides
      -- and this should boil down to f(Q) = f(Q)
      rw tag00E0.lemma15 at H2,
      have H6 := Hr Q (H HQ) H2.1,
      rw H6,
      symmetry,
      exact canonical_map.canonical_left _ _ _ _ _ }
    end⟩,
  Hid := λ U OU, funext (λ f, subtype.eq (funext (λ P, rfl))),
  Hcomp := λ U V W OU OV OW HUV HVW, funext (λ f, subtype.eq (funext (λ P, rfl)))
}

definition structure_presheaf_value {R : Type*} [comm_ring R] (U : set (X R)) (HU : is_open U) :=
(structure_presheaf_of_types_on_affine_scheme R).F U HU

lemma structure_presheaf_value.ext {R : Type*} [comm_ring R] (U : set (X R)) (HU : is_open U)
  (f g : structure_presheaf_value U HU) (h : ∀ u hu, f.1 u hu = g.1 u hu) : f = g :=
subtype.eq $ funext $ λ _, funext $ h _

instance structure_presheaf_value_has_add {R : Type*} [comm_ring R] (U : set (X R)) (HU : is_open U) :
  has_add (structure_presheaf_value U HU) :=
⟨λ f₁ f₂, ⟨λ P HP, f₁.val P HP + f₂.val P HP, λ u hu,
 let ⟨g₁, h1, h2, r₁, h3⟩ := f₁.2 u hu in
 let ⟨g₂, h4, h5, r₂, h6⟩ := f₂.2 u hu in
 ⟨g₁ * g₂,
  by rw tag00E0.lemma15; exact ⟨h1, h4⟩,
  by rw tag00E0.lemma15; exact λ z hz, h2 hz.1,
  localise_more_left _ _ r₁ + localise_more_right _ _ r₂,
  λ Q HQQ H2, begin
    have H3 := H2,
    rw tag00E0.lemma15 at H2,
    rw [h3 Q HQQ H2.1, h6 Q HQQ H2.2],
    rw [is_ring_hom.map_add (canonical_map (g₁ * g₂) Q H3)],
    rw [canonical_map.canonical_left, canonical_map.canonical_right],
    refl
  end⟩⟩⟩

instance structure_presheaf_value_has_neg {R : Type*} [comm_ring R] (U : set (X R)) (HU : is_open U) :
  has_neg (structure_presheaf_value U HU) :=
⟨λ f₁, ⟨λ P HP, -(f₁.val P HP), λ u hu,
 let ⟨g₁, h1, h2, r₁, h3⟩ := f₁.2 u hu in
 ⟨g₁, h1, h2, -r₁,
  λ Q HQQ H2, begin
    rw [is_ring_hom.map_neg (canonical_map g₁ Q H2)],
    rw [h3 Q HQQ H2]
  end⟩⟩⟩

instance structure_presheaf_value_has_mul {R : Type*} [comm_ring R] (U : set (X R)) (HU : is_open U) :
  has_mul (structure_presheaf_value U HU) :=
⟨λ f₁ f₂, ⟨λ P HP, f₁.val P HP * f₂.val P HP, λ u hu,
 let ⟨g₁, h1, h2, r₁, h3⟩ := f₁.2 u hu in
 let ⟨g₂, h4, h5, r₂, h6⟩ := f₂.2 u hu in
 ⟨g₁ * g₂,
  by rw tag00E0.lemma15; exact ⟨h1, h4⟩,
  by rw tag00E0.lemma15; exact λ z hz, h2 hz.1,
  localise_more_left _ _ r₁ * localise_more_right _ _ r₂,
  λ Q HQQ H2, begin
    have H3 := H2,
    rw tag00E0.lemma15 at H2,
    rw [h3 Q HQQ H2.1, h6 Q HQQ H2.2],
    rw [is_ring_hom.map_mul (canonical_map (g₁ * g₂) Q H3)],
    rw [canonical_map.canonical_left, canonical_map.canonical_right],
    refl
  end⟩⟩⟩

instance structure_presheaf_value_has_zero {R : Type*} [comm_ring R] (U : set (X R)) (HU : is_open U) :
  has_zero (structure_presheaf_value U HU) :=
⟨⟨λ P HP, 0, λ u hu,
  let ⟨V, ⟨f, hf⟩, huV, hVU⟩ := (D_f_form_basis R).2 U HU u hu in
  ⟨f, hf ▸ huV, hf ▸ hVU, 0, λ Q hQ h2, eq.symm $ is_ring_hom.map_zero _⟩⟩⟩

instance structure_presheaf_value_has_one {R : Type*} [comm_ring R] (U : set (X R)) (HU : is_open U) :
  has_one (structure_presheaf_value U HU) :=
⟨⟨λ P HP, 1, λ u hu,
  let ⟨V, ⟨f, hf⟩, huV, hVU⟩ := (D_f_form_basis R).2 U HU u hu in
  ⟨f, hf ▸ huV, hf ▸ hVU, 1, λ Q hQ h2, eq.symm $ is_ring_hom.map_one _⟩⟩⟩

@[simp] lemma structure_presheaf_value_add {R : Type*} [comm_ring R] (U : set (X R)) (HU : is_open U)
  (f₁ f₂ : structure_presheaf_value U HU) (u : X R) (hu : u ∈ U) :
  (f₁ + f₂).1 u hu = f₁.1 u hu + f₂.1 u hu := rfl

@[simp] lemma structure_presheaf_value_neg {R : Type*} [comm_ring R] (U : set (X R)) (HU : is_open U)
  (f₁ : structure_presheaf_value U HU) (u : X R) (hu : u ∈ U) :
  (-f₁).1 u hu = -(f₁.1 u hu) := rfl

@[simp] lemma structure_presheaf_value_mul {R : Type*} [comm_ring R] (U : set (X R)) (HU : is_open U)
  (f₁ f₂ : structure_presheaf_value U HU) (u : X R) (hu : u ∈ U) :
  (f₁ * f₂).1 u hu = f₁.1 u hu * f₂.1 u hu := rfl

instance structure_presheaf_value_is_comm_ring {R : Type*} [comm_ring R] (U : set (X R)) (HU : is_open U) :
  comm_ring (structure_presheaf_value U HU) :=
by refine
{ add := (structure_presheaf_value_has_add U HU).add,
  zero := (structure_presheaf_value_has_zero U HU).zero,
  neg := (structure_presheaf_value_has_neg U HU).neg,
  mul := (structure_presheaf_value_has_mul U HU).mul,
  one := (structure_presheaf_value_has_one U HU).one,
  zero_add := λ _, structure_presheaf_value.ext _ _ _ _ $ λ _ _, zero_add _,
  add_zero := λ _, structure_presheaf_value.ext _ _ _ _ $ λ _ _, add_zero _,
  add_left_neg := λ _, structure_presheaf_value.ext _ _ _ _ $ λ _ _, add_left_neg _,
  one_mul := λ _, structure_presheaf_value.ext _ _ _ _ $ λ _ _, one_mul _,
  mul_one := λ _, structure_presheaf_value.ext _ _ _ _ $ λ _ _, mul_one _,
  .. };
{ intros, apply structure_presheaf_value.ext, intros, { simp [mul_assoc, mul_add, add_mul] } <|> simp [mul_comm] }

definition structure_presheaf_of_rings_on_affine_scheme (R : Type*) [comm_ring R] :
  presheaf_of_rings (X R) :=
{ Fring := λ U OU,structure_presheaf_value_is_comm_ring U OU,
  res_is_ring_morphism := λ U V OU OV H, {
    map_add := λ x y,subtype.eq (funext (λ _,funext (λ _,rfl))),
    map_mul := λ x y,subtype.eq (funext (λ _,funext (λ _,rfl))),
    map_one := subtype.eq (funext (λ _,funext (λ _,rfl))),
  },
  .. structure_presheaf_of_types_on_affine_scheme R
}

definition structure_sheaf_of_rings_on_affine_scheme (R : Type*) [comm_ring R] :
  is_sheaf_of_rings (structure_presheaf_of_rings_on_affine_scheme R) :=
sorry -- don't need this to define schemes.

structure scheme :=
(α : Type u)
(T : topological_space α)
(O_X : presheaf_of_rings α)
(O_X_sheaf : is_sheaf_of_rings O_X)
(locally_affine : ∃ β : Type v, ∃ cov : β → {U : set α // T.is_open U}, 
  set.Union (λ b, (cov b).val) = set.univ ∧
  ∀ b : β, ∃ R : Type*, ∃ RR : comm_ring R, ∃ fR : (X R) → α, 
    Π H : open_immersion fR, 
    are_isomorphic_presheaves_of_rings 
      (presheaf_of_rings_pullback_under_open_immersion O_X fR H)
      (structure_presheaf_of_rings_on_affine_scheme R)
)

#print axioms scheme.mk
/-
definition presheaf_of_rings_pullback_under_open_immersion
  {α : Type*} [Tα : topological_space α]
  (U : set α) (OU : is_open U)
  (FPT : presheaf_of_types α)
  (FPR : presheaf_of_rings (FPT))
  : presheaf_of_rings (presheaf_of_types_pullback_under_open_immersion U OU FPT) := sorry 
-/

-- now back to stuff not stolen from Patrick
/-
universes u v

theorem D_f_are_a_basis {R : Type u} [comm_ring R] : ∀ U : set (X R), topological_space.is_open (Zariski R) U → ∃ α : Type v, ∃ f : α → R, U = set.Union (Spec.D' ∘ f) := sorry

definition structure_sheaf_on_union {R : Type u} [comm_ring R] {α : Type} (f : α → R) := 
  {x : (Π i : α, localization.loc R (powers $ f i)) // ∀ j k : α, localise_more_left (f j) (f k) (x j) = localise_more_right (f j) (f k) (x k) } 

-- a theorem says that this is a subring.

definition structure_sheaf (R : Type u) [comm_ring R] : {U : set (X R) // topological_space.is_open (Zariski R) U} → Type u :=
λ ⟨U,HU⟩, let exf := D_f_are_a_basis U HU in let fH := classical.some_spec exf in structure_sheaf_on_union (classical.some fH)

-- the pair consisting of Spec(R) and its structure sheaf are an affine scheme, although it is currently not even clear
-- from the definition that everything is well-defined (I choose a cover; I still didn't do the work to check that
-- the resulting ring is independent of choices (or even that it is a ring!)

-- Just begun to think about general schemes below.


-/
