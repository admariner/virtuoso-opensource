/*
 *  xmlgen.h
 *
 *  $Id$
 *
 *  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
 *  project.
 *
 *  Copyright (C) 1998-2025 OpenLink Software
 *
 *  This project is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the
 *  Free Software Foundation; only version 2 of the License, dated June 1991.
 *
 *  This program is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 *
 */

#ifndef _XMLGEN_H
#define _XMLGEN_H

#include "sqlpar.h" /* to #define ST */

extern void mpschema_set_view_def (char *name, caddr_t tree);/*mapping schema*/

struct xv_join_elt_s;
typedef struct xj_col_s
  {
    ST *	xc_exp;
    caddr_t	xc_xml_name;	/*!< DV_UNAME */
    ptrlong 	xc_usage;
    struct xv_join_elt_s * xc_relationship;
    caddr_t 	xc_prefix;	/*!< Creates valid XML ID, IDREF, and IDREFS. Prepends the values of ID,IDREF, and IDREFS with a string. */
} xj_col_t;


typedef struct xv_key_field_s
{
  caddr_t *	ids_array;
  ptrlong	ids_count;
} xv_key_field_t;

/*mapping schema*/
typedef struct xv_mp_schema_s
{
    ptrlong xj_minOccur;		/*!< The value from schema */
    ptrlong xj_maxOccur;		/*!< The value from schema, <0  means "unbounded" */
    ptrlong xj_is_constant;		/*!< The resulting XML element is not mapped to any table */
    ptrlong xj_hide_tree;		/*!< The element and its subtree do not appear in the XML document */
    ptrlong xj_hide;			/*!< The element (table) does not appear in the XML document, but its subtree does */
    ptrlong xj_mapped;			/*!< If zero then element is not mapped and the element and attributes do not appear in the XML document */
    ST * 	xj_limit_field;		/*!< Allows limiting the values that are returned on the basis of a limiting field. */
    caddr_t 	xj_limit_value;		/*!< The required value of the field specified by sql_limit_field. */
    xv_key_field_t  xj_key_fields;	/*!< Allows specification of column(s) that uniquely identify the rows in a table. */
    ptrlong	xj_use_cdata;		/*!< Allows specifying CDATA sections to be used for certain elements in the XML document. */
    ptrlong	xj_encode;		/*!< When an XML element or attribute is mapped to a SQL Server BLOB column, allows requesting a URIto be returned that can be used later to return BLOB data. */
    caddr_t	xj_overflow_field;	/*!< Identifies the database column that contains the overflow data. */
    ptrlong	xj_inverse;		/*!< Instructs the updategram logic to inverse its interpretation of the parent-child relationship that has been specified using <sql:relationship>. */
    ptrlong	xj_identity;		/*!< Can be specified on any node that maps to an IDENTITY-type database column. The value specified for this annotation defines how the corresponding IDENTITY-type column in the database is updated. */
    ptrlong	xj_guid;		/*!< Allows you to specify whether to use a GUID value generated by SQL Server or use the value provided in the updategram for that column. */
    ptrlong	xj_max_depth;		/*!< Allows you to specify depth in recursive relationships that are specified in the schema. */
    ptrlong xj_same_table;
    ST * xj_column;
    ST ** xj_parent_cols; /*key columns from the parent*/
    dk_set_t xj_child_cols; /*columns from the children*/
} xv_mp_schema_t;
/*end mapping schema*/


typedef struct xv_join_elt_s
  {
    caddr_t	xj_table;
    caddr_t	xj_prefix;
    caddr_t	xj_element;	/*!< DV_UNAME */
    xj_col_t **	xj_cols;
    ST *	xj_join_cond;
    /*! \brief Type of join with parent

        Join may be INNER or LEFT OUTER. Currently INNER may be created
        only via <CODE>CREATE XML VIEW ... FROM ... [INNER] JOIN ...</CODE>
    */
    ptrlong	xj_join_is_outer;
    ST *	xj_filter;
    struct xv_join_elt_s ** xj_children;
    struct xv_join_elt_s * xj_parent;
    caddr_t *	xj_pk;
    ptrlong	xj_all_cols_as_subelements;
    xv_mp_schema_t * xj_mp_schema; /*mapping schema*/
  } xv_join_elt_t;


/* IvAn/XmlView/000810 Type added */
/*! \brief Parameters of adding metadata into the document. */
struct xv_metas_s
  {
    /*! \brief Mode of metadata creation.
	Allowed values are:
	<TABLE>
	<TR><TD><CODE>0</CODE></TD><TD>No metadata</TD></TR>
	<TR><TD><CODE>1</CODE></TD><TD>Produce DTD, internal (i.e. inlined)</TD></TR>
	<TR><TD><CODE>2</CODE></TD><TD>Produce DTD, external DAV resource</TD></TR>
	<TR><TD><CODE>3</CODE></TD><TD>Imprint user-defined DTD text</TD></TR>
	<TR><TD><CODE>4</CODE></TD><TD>Produce XMLSchema, internal (i.e. inlined). NYI</TD></TR>
	<TR><TD><CODE>5</CODE></TD><TD>Produce XMLSchema, external DAV resource</TD></TR>
	<TR><TD><CODE>6</CODE></TD><TD>Imprint user-defined reference to XMLSchema</TD></TR>
	</TABLE> */
    caddr_t	xmetas_mode;
    caddr_t	xmetas_custom_text;	/*!< \brief User-defined text */
  };
typedef struct xv_metas_s xv_metas_t;

typedef struct xv_pub_s
  {
    caddr_t	xpub_path;
    caddr_t	xpub_owner;
    caddr_t	xpub_persistent;
    caddr_t	xpub_interval;
/* IvAn/XmlView/000810 Type added */
    caddr_t	xpub_metas;		/*!< \brief Parameters of metadata, of actual type <CODE>xv_metas_t *</CODE> */
  } xv_pub_t;

struct xml_view_nsdef_s
  {
    caddr_t	xvns_prefix;
    caddr_t	xvns_uri;
  };

typedef struct xml_view_nsdef_s xml_view_nsdef_t;

struct xml_view_s
  {
    /* must coincide with the view_def case in sql_tree_t, for all leading data members */
    ptrlong		type;
    caddr_t		xv_full_name;
    ST * 		vv_tree;
    caddr_t		xv_text;
    ptrlong		xv_check;
    xv_join_elt_t *	xv_tree;
    ptrlong		xv_all_cols_as_subelements;
    xv_pub_t *		xv_pub_opts;
    xml_view_nsdef_t**  xv_namespaces;
    caddr_t		xv_schema;
    caddr_t		xv_user;
    caddr_t		xv_local_name;
  };

typedef struct xml_view_s xml_view_t;

xml_view_t * xmls_view_def (char * name);

#endif /* _XMLGEN_H */
