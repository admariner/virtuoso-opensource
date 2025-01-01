BEGIN {
#  
#  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
#  project.
#  
#  Copyright (C) 1998-2025 OpenLink Software
#  
#  This project is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation; only version 2 of the License, dated June 1991.
#  
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#  General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
#  
#  
      print "--"
      print "-- This file is automatically generated by xsd2sql.awk, please do not edit"
      print "--"
      filename = ""
}

/.*/ {
  if (filename != FILENAME)
    {
      if (filename != "")
        {
          print "  return string_output_string (ses);"
	  print "}"
	  print ";"
        }
      filename = FILENAME
      n = split (filename, path_parts_array, "/")
      print ""
      print ""
      print "-- " path_parts_array[n] "\n"
      end_name = path_parts_array[n]
      gsub (/\./, "_", end_name)
      if (mode == "sql")
	{
          print "CREATE PROCEDURE " toupper(prefix) "_" toupper(end_name) " (IN UID INTEGER)"
	}
      else
	{
	  print "CREATE PROCEDURE " toupper(prefix) "_" toupper(end_name) " ()"
	}
      print "{"
      print "  declare ses any;"
      print "  ses := string_output ();"
    }
  str = $0
  gsub ( "\\\\", "&&", str)
  gsub ( /'/, "\\'", str)

  #
  #  Remove block comments
  #
  comment_end = index (str, "-->");
  comment_start = index (str, "<!--");
  if (in_comment == 1 && comment_end > 0)
    {
      in_comment = 0;
      next;
    }
  if (comment_start == 1 && comment_end == 0)
    {
      in_comment = 1;
    }

  if (in_comment > 0)
    {
      next;
    }

  if (mode == "sql")
    {
      gsub ( /=[\ \t]*\?/, "= \\'<UID>\\'", str)
    }

  print "  http ('" str "\\n', ses);"
}

END {
      if (mode == "sql")
	{
          print "  ses := string_output_string (ses);"
	  print "  ses := replace (ses, '<UID>', cast (UID as varchar));"
	  print "  return ses;"
	}
      else
	{
          print "  return string_output_string (ses);"
	}
	  print "}"
	  print ";"
}
