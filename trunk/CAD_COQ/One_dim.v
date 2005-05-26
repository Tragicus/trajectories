Require Import Qabs_rec.
Require Import CAD_rec.
Require Import Utils.


Section ONE_DIM.

Variable Rat_struct : Rat_ops.



  Let Coef:= Rat Rat_struct.
  Let c0 :=R0 Rat_struct.
  Let  c1 := R1 Rat_struct.
  Let cadd :=  Rat_add Rat_struct.
  Let copp :=  Rat_opp Rat_struct.
  Let  cmul :=  Rat_prod Rat_struct.
  Let csub := Rat_sub Rat_struct.
  Let cdiv := Rat_div Rat_struct.
  Let czero_test := Rat_zero_test Rat_struct.
  Let cpow := Rat_pow Rat_struct.
  Let cof_pos := Rat_of_pos Rat_struct.

 Let C_base := Rat Rat_struct.

  Let cis_base_cst := fun x:C_base => true.
  Let cmkPc := fun x:C_base => x.
  Let cmult_base_cst := cmul.
  Let cdiv_base_cst := cdiv.
  Let cell_point := unit.
  Let cvalue_bound(x:unit)(y:C_base):=(y,y).
  Let ccell_point_up_refine(x:unit):=x.
  Let csign_at(x:Coef)(u:unit):=Rat_sign Rat_struct x.
  Let cdeg(x:Coef):=N0.
  Let ccell_refine(u:unit):=u.
  Let cCert := C_base.
  Let mk_cert(c:Coef):=c.

  Load Gen_functor.

(*Are now available:
   Pol_add :Pol -> Pol->Pol
   Pol_mul :Pol->Pol->Pol
   Pol_sub :Pol->Pol->Pol
   Pol_opp :Pol->Pol
   Pol_div:Pol->Pol->Pol
   Pol_zero_test : Pol->bool
   mk_PX := Pol ->positive -> Coef -> Pol
   Pol_of_pos := positive -> Pol
   Pol_pow := Pol -> N -> Pol
   Pol_subres_list := Pol -> Pol-> list Pol
   Pol_subres_coef_list := Pol -> Pol -> list Coef
   Pol_gcd := Pol -> Pol -> Pol
   Pol_square_free := Pol -> Pol
   Pol_deriv := Pol -> Pol
   Pol_eval := Pol -> Coef -> Coef.
   Pol_trunc : Pol  -> list Pol 
   Pol_mk_coef : 
   Pol_mkPc := 
   Pol_is_base_cst 
   Pol_mult_base_cst
   Pol_div_base_cst 
   Pol_partial_eval 
   Pol_trunc
   Pol_bern_coefs
   Pol_bern_split*)

                       (************************)
                       (***  Real root  isolation ****)
                       (************************)

Let  sum_abs_val_coef:=
fix sum_abs_val_coef (P:Pol):C_base:=
     match P with
       |Pc p => rabs_val p
       |PX P' i p => (rabs_val p) ++ sum_abs_val_coef P' 
     end.
   
Let  Pol_up_bound(P:Pol):=
     let p:= Pol_dom P in
       ((sum_abs_val_coef P)//(rabs_val p))++r1.

Let Pol_up_bound_tt(P:Pol)(u:unit):=Pol_up_bound P.

Let root_low_bound1:=
   fix root_low_bound1(P:Pol)(sum:C_base){struct P}:C_base :=
     match P with
       |Pc p => sum // p
       |PX P' i p' => 
	 if (rzero_test p')
	   then root_low_bound1 P' sum
	   else sum // (rabs_val p')
     end.

 Let  Pol_low_bound (P:Pol) := ropp (root_low_bound1 P (sum_abs_val_coef P))++r1).

 Let Pol_low_bound_tt(P:Pol)(u:unit):=Pol_low_bound P.

Let Pol_low_sign(P:Pol)(u:unit):=
let low := ropp ((Pol_low_bound P) ++ r1) in
Some  (rsign (Pol_eval P low)).
(*
Inductive TagRoot : Set :=
     |Singl : C_base -> TagRoot
     |Pair : C_base -> C_base -> Pol -> Pol -> (list Coef) -> TagRoot
     |Minf : TagRoot.

 
 Let isol_box := TagRoot.
*)
(*isolates roots of P over ]c d[ *)
Let root_isol1(P:Pol)(ubound lbound:C_base)(Pbar:Pol)(degPbar:N):=
   fix root_isol1(res:list (isol_box*(list Sign)))
     (c d:C_base)(blist: list C_base)(n:nat){struct n}:
     list (isol_box*(list Sign)):=
     if rlt d c 
       then nil
       else
	 let Vb := sign_changes (map rsign blist) in
	   match Vb  with
	     |O => res
	     |S O =>
	       if negb (rzero_test ((Pol_eval P c)**(Pol_eval P d)))
		 then ((Pair tt (c,d) P Pbar blist), (Some Eq)::nil)::res
		   else
		     match n with
		       |O => (Pair tt (c,d) P Pbar blist, None::nil)::res
		       |S n' => 
			 let mid := (d ++ c) // (2 # 1) in
			 let (b', b''):= Pol_bern_split blist c d mid in
			 let res':= root_isol1 res c  mid  b' n' in
			   if (rzero_test (Pol_eval Pbar mid)) 
			     then
			       root_isol1 ((Singl tt mid, (Some Eq)::nil)::res')
			       mid d b'' n'
			     else
			       root_isol1 res'  mid d b'' n'
		     end
	     |_ =>
	       match n with
		 |O => (Pair tt (c,d) P Pbar blist, None::nil)::res
		 |S n' => 
		   let mid := (d ++ c) // (2 # 1) in
		     let (b', b''):= Pol_bern_split blist c d mid in
		       let res':= root_isol1 res c  mid  b' n' in
			 if rzero_test (Pol_eval Pbar mid) 
			   then
			     root_isol1 ((Singl tt mid, (Some Eq)::nil)::res') mid d b'' n'
			   else
			     root_isol1 res'  mid d b'' n'
	       end
	   end.


Let root_isol(P:Pol)(ubound lbound:C_base)(Pbar:Pol)(degPbar:N):= 
     root_isol1 P ubound lbound Pbar degPbar
     ((Minf tt lbound, Some (rsign (Pol_eval P (ropp (lbound ++ r1))))::nil)::nil)
      ubound lbound (Pol_bern_coefs Pbar (ropp lbound) ubound degPbar).
   
Let root_isol_int(P:Pol)(ubound lbound:C_base)(Pbar:Pol)(degPbar:N)
   (c d:C_base)(n:nat):list (isol_box * (list Sign)) := 
     root_isol1  P ubound lbound Pbar degPbar
     nil c d (Pol_bern_coefs Pbar c d degPbar) n.
 

(* Sign of Q at a root of P : *)


 (** which is not a root of Q*)
 (*   None means n was not large enough *)

    Let sign_at_non_com(Q Qbar:Pol)(dQbar:N):=
    fix sign_at_non_com(a b:C_base)(P Pbar:Pol)(bern bernQ:list C_base)
     (n:nat){struct n}: (isol_box* Sign):=
     let test := sign_changes (map rsign bernQ) in
       match test with
	 |O => (Pair tt (a,b) P Pbar bern, (Some (rsign (Pol_eval Q a))))
	 |S _ => 
	   let mid := (a ++ b) // (2 # 1) in
	     let Pbar_mid := Pol_eval Pbar mid in
	       if rzero_test Pbar_mid
		 then (Singl tt mid , (Some (rsign (Pol_eval Q mid))))
		 else
		   match n with
		     |O => (Pair tt (a,b) P Pbar bern, None)
		     |S m =>
		       match rsign (Pbar_mid**(Pol_eval Pbar a)) with
			 | Lt  =>
			   let (bern',_) := Pol_bern_split bern a b mid in
			     let (bernQ',_) := Pol_bern_split bernQ a b mid in
			       sign_at_non_com a mid P Pbar bern' bernQ' m
			 |_ =>
			   let (_,bern'') := Pol_bern_split bern a b mid in
			     let (_,bernQ'') := Pol_bern_split bernQ a b mid in
			       sign_at_non_com mid b P Pbar bern'' bernQ'' m
		       end
		   end
       end.




  (* refines ]ab[ which contains a unique root of P and G=gcd P Q
    to a intervalle which isolates for Q *)

  Let sign_at_com :=
   fix sign_at_com(a b:C_base)(P Pbar G Gbar:Pol)
     (bernG bernQ:list C_base)(n:nat){struct n}:
     isol_box*Sign:=
     let VbQ := sign_changes (map rsign bernQ) in  
       match VbQ with
	 |O => (Pair tt (a,b) G Gbar bernG, None) (*never!*)
	 |S O => (Pair tt (a,b) G Gbar bernG, (Some Eq))
	 |S _ =>
	   let mid := (a ++ b) // (2 # 1) in
	     let Pbar_mid := (Pol_eval Pbar mid) in
	       if rzero_test Pbar_mid
		 then 
		   (Singl tt mid, (Some Eq))
		 else
		   match n with
		     |O => (Pair tt (a,b)G Gbar bernG, None)
		     |S n' =>
		       match rsign (Pbar_mid**(Pol_eval Pbar a)) with
			 |Lt =>
			   let (bernG',_):=Pol_bern_split bernG a b mid in
			     let (bernQ',_):= Pol_bern_split bernQ a b mid in
			       sign_at_com a mid P Pbar G Gbar bernG' bernQ' n'
			 |_ =>
			   let (_,bernG''):=Pol_bern_split bernG a b mid in
			     let (_,bernQ''):=Pol_bern_split bernQ a b mid in
			       sign_at_com mid b P Pbar G Gbar bernG'' bernQ'' n'
		       end
		   end
       end.



     (*refines a Pair to determine the sign of Q at that root of P
    G = gcd P Q, ie up to the point where G has either a unique root or no root*)

Let pair_refine (Q Qbar:Pol)(dQbar:N):=
 fix pair_refine(a b:C_base)(P Pbar G:Pol)
     (bern bernG:list C_base)(n:nat){struct n}:
     isol_box*Sign:=
     let VbG := sign_changes (map rsign bernG) in
       match VbG with
	 |O => 
	   let bernQ := Pol_bern_coefs Qbar a b dQbar in
	     sign_at_non_com Q Qbar dQbar a b P Pbar bern bernQ n 
	 |S O =>
	   let bernQ := Pol_bern_coefs Qbar a b dQbar in
	   let Gbar := Pol_square_free G in
	     sign_at_com a b P Pbar G Gbar bernG bernQ n
	 |_ =>
	   let mid := (a ++ b) // (2 # 1) in
	     let Pbar_mid := (Pol_eval Pbar mid) in
	       if rzero_test Pbar_mid
		 then 
		   (Singl tt mid, Some (rsign (Pol_eval Q mid)))
		 else
		   match n with
		     |O => (Pair tt (a,b) P Pbar bern, None)
		     |S m =>
		       match rsign (Pbar_mid**(Pol_eval Pbar a)) with
			 |Lt =>
			   let (bern',_):=Pol_bern_split bern a b mid in
			     let (bernG',_):=Pol_bern_split bernG a b mid in
			       pair_refine
			       a mid P Pbar G bern' bernG' m
			 |_ =>
			   let (_,bern''):=Pol_bern_split bern a b mid in
			     let (_,bernG''):=Pol_bern_split bernG a b mid in
			       pair_refine
			       mid b P Pbar G bern'' bernG'' m
		       end
		   end
       end.



    (* Sign of Q at an element of an isolating list,
    previous failures are propagated*)

  Let sign_at_root(Q Qbar:Pol)(dQbar:N)(low:Sign)(t:isol_box)(n:nat):
     isol_box*Sign:=
       match t with
	 |Minf _ m => (Minf tt m, low)
	 |Singl _ r => 
	   (Singl tt r, Some (rsign (Pol_eval Q r)))
	 |Pair _ (a,b) P Pbar bern =>
	     let G := Pol_gcd Q P in
	       let dG := Pol_deg G in
		 let bernG := Pol_bern_coefs G a b dG in
		   pair_refine Q Qbar dQbar a b P Pbar G bern bernG  n
       end.
 
  Let  sign_list_at_root(Q Qbar:Pol)(dQbar:N)(low:Sign)(t:isol_box*(list Sign))(n:nat):
     isol_box*(list Sign) :=
     let (root, sign_list) :=  t in
       match sign_list with
	 |nil => 
	   let (root_res, sign_res):= sign_at_root Q Qbar dQbar low root n in
	     (root_res, sign_res::nil)
	 |None :: _ => (root, None :: sign_list)
	 |_ :: _ =>
	   let (root_res, sign_res):= sign_at_root Q Qbar dQbar low root n in
	     (root_res, sign_res::sign_list)
    end.
 
(* to add the sign of a pol to a list of signs at a tagged root*) 
 Let add_cst_sign(l:list (isol_box*(list Sign)))(sign:Sign):=
   let add_sign := fun w => (fst w, sign::(snd w)) in
     map add_sign l.

(* to add the sign of a pol at the end of a list of signs *)
 Let add_to_cst_list(l:list (isol_box*(list Sign)))(sign :list Sign):=
   let add_list := fun w => (fst w,  (snd w) @ sign) in
     map add_list l.

  (* find the sign col after a root, evaluating only if necessary *)
Let fill_sign_between :=
 fix fill_sign_between(b:C_base)(lsign:list Sign)(lpol:list Pol)
   {struct lsign}:list Sign :=
   match lsign,lpol with
     |nil,_  => nil
     |shd::stl, nil => nil
     |shd::stl, phd::ptl =>
       match shd with
	 |None =>  None ::(fill_sign_between b stl ptl)
	 |Some z =>
	   match z with
	     |Eq => (Some (rsign (Pol_eval phd b)))::(fill_sign_between b stl ptl)
	     |_ => shd :: (fill_sign_between b stl ptl)
	   end
       end
   end.



    (*  sign of P over ]low,up[, P(low)has sign lowsign P(up) has sign upsign*)
    (*l is not empty in res, work is done up to up [*)
 Let add_roots(P:Pol)(global_up global_l :C_base)(freeP:Pol)(dfreeP:N)
   (lP:list Pol) :=
fix add_roots(l:list (isol_box*(list Sign)))
   (low up:C_base)(lowsign upsign:Sign)
   (n:nat){struct l}:list (isol_box*(list Sign)) :=
   match l with
     |nil => nil
     |hd :: tl =>
       let tag := fst hd in
	 let prev_slist := snd hd in
	   match tag with
	     |Minf _ m =>
	       let resP := root_isol_int P global_up global_l freeP dfreeP  low up n in
		 ((add_to_cst_list resP prev_slist)@
		   (Minf tt m, (Some (rsign (Pol_eval P (low -- r1))))::prev_slist)::nil)
	     |Singl _ r =>
	       if orb (rlt up r) (rzero_test (r -- up))
		 then
		   (tag,  upsign::prev_slist)::
		   (add_roots tl low r lowsign upsign n)
		 else
		   let signP_r := rsign (Pol_eval P r) in			
		     let resP := root_isol_int P global_up global_l freeP dfreeP r up n in
		       let prev_next_sign := fill_sign_between ((r++ up)//(2 # 1))
			 prev_slist lP in
			 let res_r_up := (add_to_cst_list resP prev_next_sign) in
			   res_r_up @
			   ((Singl tt r, (Some signP_r):: prev_slist)::
			     (add_roots tl low r  lowsign (Some signP_r) n))
	     |Pair _ (a,b) Q Qbar bern =>
	       let refine := sign_list_at_root P freeP dfreeP lowsign hd n in
		 match (fst refine) with
		   |Minf _  m => (Minf tt m, None :: prev_slist):: tl (*should never happen*)
		   |Singl _ r =>
		     if orb (rlt up r) (rzero_test (r -- up))
		       then
			 refine::
			   (add_roots  tl low r lowsign upsign n)
		       else
			 let signP_r :=
			   match snd refine with
			     |nil => None
			     |s :: tl => s
			   end in
			   let prev_next_sign :=
			     fill_sign_between ((r++up)//(2#1)) prev_slist lP in
			     let resP := (root_isol_int P global_up global_l freeP dfreeP r up n) in
			       let res_r_up := (add_to_cst_list resP prev_next_sign) in
				 res_r_up @
				 (refine::
				   (add_roots tl low r  lowsign 
				     signP_r n))
		   |Pair _ (a', b') Q' Qbar' bern' =>
		     if orb (rlt up a') (rzero_test (a' -- up))
		       then
			 refine::
			   (add_roots tl  low a' lowsign upsign n)
		       else
			 let Pa' := Pol_eval P a' in
			   let Pb' := Pol_eval P b' in
			     let prev_next_sign :=
			       fill_sign_between ((b'++up)//(2#1)) prev_slist lP in
			       let resP := (root_isol_int P global_up global_l freeP dfreeP b' up n) in
				 let res_b'_up := (add_to_cst_list resP prev_next_sign) in
				   match (rzero_test Pb'), (rzero_test Pa') with
				     |true, false =>
				       res_b'_up @
				       ((Singl tt b', (Some Eq)::prev_next_sign)::
					 refine::
					   (add_roots  tl low a' 
					     lowsign (Some (rsign Pa')) n))
				     |false, true =>
				       let prev_a'_sign :=
					 map (fun P => Some (rsign (Pol_eval P a'))) lP in
					 res_b'_up@
					 (refine ::
					   (Singl tt a', (Some Eq)::prev_a'_sign)::
					   (add_roots  tl low a'
					     lowsign (Some (rsign Pa')) n))
				     |true, true =>
				       let prev_a'_sign :=
					 map (fun P => Some (rsign (Pol_eval P a'))) lP in
					 res_b'_up @
					 ((Singl tt b', (Some Eq)::prev_next_sign)::
					   refine ::
					     (Singl tt a', (Some Eq)::prev_a'_sign)::
					     (add_roots tl low a'  
					       lowsign (Some (rsign Pa')) n))
				     |false, false =>
				       res_b'_up @ 
				       (refine::
					 (add_roots tl low a'  
					   lowsign (Some (rsign Pa')) n))
				   end
		 end
	   end
   end.	


  (*head is the biggest root, computes the isolating list*)
Let family_root := 
 fix family_roots(Pol_list : list Pol)(n:nat)
   {struct Pol_list}:list (isol_box*(list Sign)):=
   match Pol_list with
     |nil => nil
     |P :: tl =>
     let Pfree := Pol_square_free P in
     let dPfree := Pol_deg Pfree in
     let P_low := (ropp (Pol_low_bound P)) -- r1 in
     let P_up := (Pol_up_bound P)++ r1 in
     let upsign := rsign (Pol_eval P P_up) in
     let lowsign := rsign (Pol_eval P P_low) in
       match tl with
	 |nil => root_isol P P_up P_low Pfree dPfree n
	 |_ =>
	   let prev := family_roots tl n in
	   
		       add_roots P P_up P_low Pfree dPfree tl prev P_low P_up (Some lowsign) (Some upsign) n
       end
   end.

 

(* One point per cell 
 Inductive Index : Set :=
   |Root : isol_box -> Index
   |Between : C_base -> Index.
*)
Let sign_at_index(c:four_uple Pol Pol N Sign)(t:cell_point_up)(n:nat):=
let (Q, Qbar,dQbar,low):= c in
   match t with
   |Root t => let (tag_res,sign_res) := sign_at_root Q Qbar dQbar low t n in
   (Root tag_res, sign_res)
   |Between _ b => (Between tt b, Some (rsign (Pol_eval Q b)))
   end.


  (*sign table for the family up to "up",included.
    up is not a root 
     head corresponds to the smallest root*)
Let sign_table1 (glow gup:C_base):=
 fix sign_table1(Pol_list : list Pol)
   (isol_list : list (isol_box*(list Sign)))
  (up:C_base)
     (res:list (cell_point_up*(list Sign))){struct isol_list}:
   list (cell_point_up*(list Sign)):=
   let Sign_eval := (fun x P =>
     Some (rsign (Pol_eval P x))) in
   match isol_list with
     |nil => res
     |hd::tl =>
       let hdTag := fst hd in
	 let hdSign := snd hd in
	   match hdTag with
	     |Minf _  m=> (Between tt glow, hdSign)::res
	     |Singl _ r =>
	       let bet := (r ++ up)//(2 # 1) in
		 match res with
		   |nil =>sign_table1 Pol_list tl r 
		     ((Root hdTag, hdSign) ::
		       ((Between tt up, fill_sign_between bet hdSign Pol_list)::res))
		   |_ =>
		     sign_table1 Pol_list tl r 
		     ((Root hdTag, hdSign) ::
		       ((Between tt bet,fill_sign_between bet hdSign Pol_list)::res))
		 end
	     |Pair _ (a,b) _ _ _ =>
	       let bet := (b ++ up)//(2#1) in
		 match res with
		   |nil =>
		     sign_table1 Pol_list tl a
		     ((Root hdTag, hdSign)
		       ::((Between tt gup,fill_sign_between bet hdSign Pol_list) ::res))
		   |_ =>
		     sign_table1 Pol_list tl a
		     ((Root hdTag, hdSign)
		       ::((Between tt bet,fill_sign_between bet hdSign Pol_list) ::res))
		 end
	   end
   end.

 Let sign_table(Pol_list:list Pol)(n:nat):=
   let up := rmax_list (map Pol_up_bound Pol_list)in
   let low := rmax_list (map Pol_low_bound Pol_list) in
     let roots := family_root Pol_list n in
       (sign_table1 low up Pol_list roots up nil).


Let isol_box_proj(u:cell_point_up) := tt.


  Let cert_refine(z:cell_point)(P Pbar:Pol)(a b:Coef)(c:list cCert)(n:nat):=
     let mid := rdiv (radd a b) (2#1) in
     let Pmid := Pol_partial_eval P mid in
     let Pbarmid := Pol_partial_eval Pbar mid in
	match csign_at Pmid z with 
        |Eq => Singl z mid
	| _ =>
           let (b',b''):=Pol_bern_split c a b mid in
	   let Vb' := sign_changes (map (fun x => (csign_at x z)) b') in
	   match Vb' with
	|1 => Pair z (a,mid) P Pbar b'
	|_ => Pair z (mid, b) P Pbar b''
	end
	end.

Let cell_point_up_refine(z:cell_point_up)(n:nat) :=
   match z with
   |Root ibox => let res:=
	match ibox with
	 |Singl z' r => (Singl (ccell_point_up_refine z') r)
	 |Pair z' (a,b) P Pbar c => let z'':= ccell_point_up_refine z' in cert_refine z''  P Pbar a b c n
	 |Minf z' m => Minf (ccell_refine z') m
end in Some (Root res)
   |Between z' b => Some (Between (ccell_point_up_refine z') b)
  
end.

Let Cert_fst(c:Cert):= four_fst c.


Definition One_dim_cad := @mk_cad Rat_struct
 C_base c0 c1 cadd cmul csub copp czero_test cof_pos cpow cdiv 
 Pol 
 P0 P1
 Pol_add Pol_mul Pol_sub Pol_opp Pol_deg mkPX 
  Pol_zero_test   Pol_of_pos  Pol_pow   Pol_div
  Pol_subres_list  Pol_subres_coef_list
  Pol_gcd   Pol_square_free   Pol_deriv 
  Pol_eval   Pol_is_base_cst 
  Pol_mkPc   cmkPc 
  Pol_mult_base_cst   Pol_div_base_cst 
  Pol_partial_eval  unit cell_point_up isol_box_proj cell_point_up_refine
  Pol_low_bound_tt Pol_up_bound_tt 
  Pol_low_sign Pol_value_bound Cert mk_Cert build_Cert Cert_fst 
  sign_at_index sign_table.

End ONE_DIM.


(* surement des trucs a optimiser avec Minf *)







