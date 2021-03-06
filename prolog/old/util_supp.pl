/* Part of LogicMOO Base Logicmoo Path Setups
% ===================================================================
    File:         'logicmoo_util_library.pl'
    Purpose:       To load the logicmoo libraries as needed
    Contact:       $Author: dmiles $@users.sourceforge.net ;
    Version:       'logicmoo_util_library.pl' 1.0.0
    Revision:      $Revision: 1.7 $
    Revised At:    $Date: 2002/07/11 21:57:28 $
    Author:        Douglas R. Miles
    Maintainers:   TeamSPoon
    E-mail:        logicmoo@gmail.com
    WWW:           http://www.prologmoo.com
    SCM:           https://github.com/TeamSPoon/PrologMUD/tree/master/pack/logicmoo_base
    Copyleft:      1999-2015, LogicMOO Prolog Extensions
    License:       Lesser GNU Public License
% ===================================================================
*/

end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.

:- if(\+ current_predicate(system:must_or_die/1)).
:- module(logicmoo_util_supp,[must_or_die/1,must_atomic/1,nop/1,quietly/1,each_call_cleanup/3]).
:- endif.
% % :- '$set_source_module'(system).
:- meta_predicate
      must_atomic(0),
      must_notrace(0),
      must_zotrace(0),
      must_or_die(0),      
      quietly(0),
      nop(0),
      each_call_cleanup(0,0,0),
      call_cleanup_each(0,0).

:- if(\+ current_predicate(system:nop/1)).
:- user:ensure_loaded(logicmoo_util_supp).
:- endif.


%% nop( ?VALUE1) is semidet.
%
% Nop.
%
:- if( \+ current_predicate(nop/1)).
:- export(nop/1).
nop(_).
:- endif.

:- if(\+ current_predicate(system:must_or_die/1)).

:- module_transparent(must_or_die/1).
:- '$hide'(must_or_die/1).
% must_or_die(Goal):- (catch(Goal,E,(writeq(e_xxXXXXXX_xxxxxxxx_failed_must_or_die(E)),nl,fail)) *-> true ; (dtrace,Goal*->true;throw(failed_must_or_die(Goal)))).
system:must_or_die(Goal):- (Goal *-> true ; throw(failed_must_or_die(Goal))).

:- module_transparent(must_atomic/1).
:- '$hide'(must_atomic/1).
system:must_atomic(Goal):- must_or_die(zotrace(('$sig_atomic'(Goal)))).

:- module_transparent(must_notrace/1).
:- '$hide'(must_notrace/1).
system:must_notrace(Goal):- quietly(must_or_die(Goal)).
system:must_zotrace(Goal):- quietly(must_or_die(Goal)).

:- if(\+ current_predicate(quietly/1)).
:- module_transparent(quietly/1).
:- '$hide'(quietly/1).
quietly(G):- !,call(G).
quietly(G):- zotrace((tracing,notrace))->
   each_call_cleanup(zotrace(notrace),G,zotrace(trace)); 
   each_call_cleanup(zotrace(notrace),G,zotrace(notrace)).
:- endif.

:- module_transparent(call_cleanup_each/2).
:- '$hide'(call_cleanup_each/2).
call_cleanup_each(Goal, Cleanup) :-
  each_call_cleanup(true, Goal, Cleanup).

:- module_transparent(each_call_cleanup/3).
:- '$hide'(each_call_cleanup/3).

:- if( \+ current_predicate(each_call_cleanup/3)).
:- export(each_call_cleanup/3).
:- meta_predicate(each_call_cleanup(0,0,0)).
each_call_cleanup(Setup,Goal,Cleanup):- 
   (current_prolog_flag(scce,Pred) ->
    (Pred==pure ->
     catch((
        call((must_atomic(Setup),Goal,deterministic(Det),true))
        *->
        (Det == true
          -> (must_atomic(Cleanup),!)
          ; (must_atomic(Cleanup);(must_atomic(Setup),fail)))
     ; (must_atomic(Cleanup),!,fail)),
     E, (ignore(must_atomic(Cleanup)),throw(E)));
     call(Pred,Setup,Goal,Cleanup))
    ;setup_call_cleanup(Setup,Goal,Cleanup)).

:- endif.

:- endif.


end_of_file.


:-export(call_using_first_responder/1).
:-meta_predicate(call_using_first_responder(0)).
call_using_first_responder(Call):- 
  Responded = responded(_),Cutted = was_cut(_),

  CheckCut = (ignore(deterministic(HasCut)),(HasCut=true->nb_setarg(1,Cutted,cut);true)),
  
  clause(Call,Body),
  \+ ground(Cutted),
  FakeBody = (Body;fail),
  ((( (FakeBody,CheckCut,nb_setarg(1,Responded,answered)) *-> true ; (CheckCut,fail))
     ; (CheckCut,ground(Responded),((HasCut==true->!;true)),fail))).


 % one_must(C1,one_must(C2,one_must(C3,one_must(C4,C5)))).



a:- !,fail.
a:- throw(failed_test).
fr1:- \+ call_using_first_responder(a).


b:- !.
b:- throw(failed_test).
fr2:- call_using_first_responder(b).

wa(A):-writeln(A),asserta(A).

c:- fail.
c:- !, (wa(c(2));wa(c(3))).
c:- throw(failed_test).
fr3:- call_using_first_responder(c).



d:- wa(d(1));(wa(d(2));wa(d(3))).
d:- throw(failed_test).
fr4:- call_using_first_responder(d).

:- break.
