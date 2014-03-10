#define PERL_NO_GET_CONTEXT
/* For versions of ExtUtils::ParseXS > 3.04_02, we need to
 * explicitly enforce exporting of XSUBs since we want to
 * refer to them using XS(). This isn't strictly necessary,
 * but it's by far the simplest way to be backwards-compatible.
 */
#define PERL_EUPXS_ALWAYS_EXPORT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <assert.h>

#ifndef SvREFCNT_dec_NN
# define SvREFCNT_dec_NN(a) SvREFCNT_dec(a)
#endif
#ifndef SvREFCNT_inc_NN
# define SvREFCNT_inc_NN(a) SvREFCNT_inc(a)
#endif

typedef SV * obj_struct_obj_t;

/* Install a new XSUB under 'name' and set the function index attribute
 * Requires a previous declaration of a CV* cv!
 **/
#define INSTALL_NEW_CV_WITH_UV(name, xsub, value)                           \
STMT_START {                                                                \
  CV *cv = newXS(name, xsub, (char*)__FILE__);                              \
  if (cv == NULL)                                                           \
    croak("ARG! Something went really wrong while installing a new XSUB!"); \
  XSANY.any_uv = value;                                                     \
} STMT_END

/* Install a new XSUB under 'name' and set the function index attribute
 * Requires a previous declaration of a CV* cv!
 **/
#define INSTALL_NEW_CV_WITH_PTR(name, xsub, user_pointer)                   \
STMT_START {                                                                \
  CV *cv = newXS(name, xsub, (char*)__FILE__);                              \
  if (cv == NULL)                                                           \
    croak("ARG! Something went really wrong while installing a new XSUB!"); \
  XSANY.any_ptr = (void *)user_pointer;                                     \
} STMT_END

#define OS_XSUB_NAME(name) XS_Object__Struct_ ## name

XS(OS_XSUB_NAME(constructor));
XS(OS_XSUB_NAME(destructor));
XS(OS_XSUB_NAME(accessor));


SV *
make_fqn(pTHX_ SV *class_name, const char *sub_name, size_t sub_name_len)
{
  SV *fqn;
  fqn = sv_2mortal(newSVsv(class_name));
  sv_catpvs(fqn, "::");
  sv_catpvn(fqn, sub_name, sub_name_len);
  return fqn;
}

MODULE = Object::Struct    PACKAGE = Object::Struct

REQUIRE: 2.2201

void
make_class(class_name, attrs)
    SV *class_name
    AV *attrs;
  PREINIT:
    SV *fqn;
    char *name;
    UV i;
    UV nattrs;
    STRLEN len;
    char *str;
    SV **svp;
  CODE:
    nattrs = (UV)(av_len(attrs)+1);

    fqn = make_fqn(aTHX_ class_name, "new", 3);
    name = SvPVX(fqn);
    INSTALL_NEW_CV_WITH_UV(name, OS_XSUB_NAME(constructor), nattrs);

    fqn = make_fqn(aTHX_ class_name, "DESTROY", 7);
    name = SvPVX(fqn);
    INSTALL_NEW_CV_WITH_UV(name, OS_XSUB_NAME(destructor), nattrs);

    for (i = 0; i < nattrs; ++i) {
      svp = av_fetch(attrs, i, 0);
      if (!svp)
        croak("Need array ref of attribute names");

      str = SvPV(*svp, len);
      fqn = make_fqn(aTHX_ class_name, str, len);
      name = SvPVX(fqn);
      INSTALL_NEW_CV_WITH_UV(name, OS_XSUB_NAME(accessor), i);
    }


obj_struct_obj_t *
constructor(CLASS, ...)
    char *CLASS;
  PREINIT:
    UV nmembers;
    SV **data;
    UV i;
  CODE:
    nmembers = XSANY.any_uv;
    Newx(data, nmembers, SV *);
    for (i = 0; i < nmembers; ++i)
      data[i] = &PL_sv_undef;
    RETVAL = (obj_struct_obj_t *)data;
  OUTPUT: RETVAL


void
destructor(invocant)
    obj_struct_obj_t *invocant;
  PREINIT:
    SV **data;
    UV nmembers;
    UV i;
  CODE:
    data = (SV **)invocant;
    nmembers = XSANY.any_uv;
    for (i = 0; i < nmembers; ++i) {
      assert(data[i]);
      SvREFCNT_dec_NN(data[i]);
    }
    Safefree(data);

void
accessor(invocant, ...)
    obj_struct_obj_t *invocant;
  PREINIT:
    SV **data;
    UV member_num;
  PPCODE:
    data = (SV **)invocant;
    member_num = XSANY.any_uv;
    if (items > 1) {
      SV* newvalue = ST(1);
      assert(newvalue);
      SvREFCNT_inc_NN(newvalue);
      data[member_num] = newvalue;
      PUSHs(newvalue);
    }
    else {
      PUSHs(data[member_num]);
    }
