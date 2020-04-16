type t =
  | Eq of string option * Poly.t * Poly.t
  | Ineq of string option * Poly.t * Poly.t

let to_string ?(short = false) c =
  let p_string = Poly.to_string ~short in
  match c with
  | Eq (Some name, lhs, rhs) ->
      name ^ ": " ^ String.concat " = " [p_string lhs; p_string rhs]
  | Eq (None, lhs, rhs) ->
      String.concat " = " [p_string lhs; p_string rhs]
  | Ineq (Some name, lhs, rhs) ->
      name ^ ": " ^ String.concat " <= " [p_string lhs; p_string rhs]
  | Ineq (None, lhs, rhs) ->
      String.concat " <= " [p_string lhs; p_string rhs]

let simplify_sides lhs rhs =
  let l = Poly.partition lhs in
  let r = Poly.partition rhs in
  let newl = Poly.(fst l @ ~-(fst r)) in
  let newr = Poly.(snd r @ ~-(snd l)) in
  (Poly.simplify newl, Poly.simplify newr)

let simplify = function
  | Eq (name, lhs, rhs) ->
      let s = simplify_sides lhs rhs in
      Eq (name, fst s, snd s)
  | Ineq (name, lhs, rhs) ->
      let s = simplify_sides lhs rhs in
      Ineq (name, fst s, snd s)

let take_vars = function
  | Eq (_, lhs, rhs) | Ineq (_, lhs, rhs) ->
      Poly.take_vars lhs @ Poly.take_vars rhs

let eq ?(name = None) lhs rhs =
  let s = simplify_sides lhs rhs in
  Eq (name, fst s, snd s)

let lt ?(name = None) lhs rhs =
  let s = simplify_sides lhs rhs in
  Ineq (name, fst s, snd s)

let gt ?(name = None) lhs rhs =
  let s = simplify_sides rhs lhs in
  Ineq (name, fst s, snd s)

let ( =$ ) l r = eq l r

let ( <$ ) l r = lt l r

let ( >$ ) l r = gt l r

let trans_bound name lb ub = function
  | Eq (n, l, r) ->
      let newl = Poly.trans_bound name lb ub l in
      let newr = Poly.trans_bound name lb ub r in
      Eq (n, newl, newr)
  | Ineq (n, l, r) ->
      let newl = Poly.trans_bound name lb ub l in
      let newr = Poly.trans_bound name lb ub r in
      Ineq (n, newl, newr)

let to_integer name = function
  | Eq (n, l, r) ->
      let newl = Poly.to_integer name l in
      let newr = Poly.to_integer name r in
      Eq (n, newl, newr)
  | Ineq (n, l, r) ->
      let newl = Poly.to_integer name l in
      let newr = Poly.to_integer name r in
      Ineq (n, newl, newr)

let to_binary name = function
  | Eq (n, l, r) ->
      let newl = Poly.to_binary name l in
      let newr = Poly.to_binary name r in
      Eq (n, newl, newr)
  | Ineq (n, l, r) ->
      let newl = Poly.to_binary name l in
      let newr = Poly.to_binary name r in
      Ineq (n, newl, newr)
