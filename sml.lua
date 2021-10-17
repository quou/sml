-- This script generates the SML header.

-- Copyright © 2021 veridis_quo_t
--
-- Permission is hereby granted, free of charge, to any
-- person obtaining a copy of this software and associated
-- documentation files (the “Software”), to deal in the
-- Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute,
-- sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:
--
-- The above copyright notice and this permission notice
-- shall be included in all copies or substantial portions of
-- the Software.
--
-- THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY
-- KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
-- OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
-- USE OR OTHER DEALINGS IN THE SOFTWARE.

-- This table allows configuration and adding different types.
config = {
	outfile = "sml/sml.h",

	impl_def = "SML_IMPL",
	typedef_integers = true,
	typedef_structs = true,

	-- Match this with the rest of your project.
	indent_style = "tabs",
	indent_size = 8,

	vector_dimentions = { "x", "y", "z", "w" },
	-- Alternatives:
	-- vector_dimentions = { "a", "b", "c", "d" },
	-- vector_dimentions = { "r", "g", "b", "a" },

	vectors = {
		v2f = {
			typename = "float",
			dimentions = 2
		},
		v2d = {
			typename = "double",
			dimentions = 2
		},
		v2i = {
			typename = "i32",
			dimentions = 2
		},
		v2u = {
			typename = "u32",
			dimentions = 2
		},
		v3f = {
			typename = "float",
			dimentions = 3
		},
		v3d = {
			typename = "double",
			dimentions = 3
		},
		v3i = {
			typename = "i32",
			dimentions = 3
		},
		v3u = {
			typename = "u32",
			dimentions = 3
		},
		v4f = {
			typename = "float",
			dimentions = 4
		},
		v4d = {
			typename = "double",
			dimentions = 4
		},
		v4i = {
			typename = "i32",
			dimentions = 4
		},
		v4u = {
			typename = "u32",
			dimentions = 4
		}
	},
	matrices = {
		m2f = {
			typename = "float",
			size = 2,
			major = "column"
		},
		m2d = {
			typename = "double",
			size = 2,
			major = "column"
		},
		m2i = {
			typename = "i32",
			size = 2,
			major = "column"
		},
		m2u = {
			typename = "u32",
			size = 2,
			major = "column"
		},
		m3f = {
			typename = "float",
			size = 3,
			major = "column"
		},
		m3d = {
			typename = "double",
			size = 3,
			major = "column"
		},
		m3i = {
			typename = "i32",
			size = 3,
			major = "column"
		},
		m3u = {
			typename = "u32",
			size = 3,
			major = "column"
		},
		m4f = {
			typename = "float",
			size = 4,
			major = "column"
		},
		m4i = {
			typename = "i32",
			size = 4,
			major = "column"
		},
		m4u = {
			typename = "u32",
			size = 4,
			major = "column"
		},
		m4d = {
			typename = "double",
			size = 4,
			major = "column"
		}
	}
}

function_generators = {
	global = {
		torad = {
			prototype = function()
				return "double torad(double deg)"
			end,

			impl = function()
				return "return deg * (pi / 180.0);"
			end
		},

		todeg = {
			prototype = function()
				return "double todeg(double rad)"
			end,

			impl = function()
				return "return rad * (180.0 / pi);"
			end
		}
	},

	vector = {
		vector_construct = {
			prototype = function(name, struct_typename, value_typename, dimention_count)
				local str = string.format("%s make_%s(", struct_typename, name)

				for i = 1, dimention_count do
					str = str .. string.format("%s %s", value_typename, config.vector_dimentions[i])

					if i < dimention_count then
						str = str .. ", "
					end
				end

				str = str .. ")"

				return str
			end,
			impl = function(name, struct_typename, value_typename, dimention_count)
				local str = string.format("return (%s) { ", struct_typename)

				for i = 1, dimention_count do
					str = str .. string.format("%s", config.vector_dimentions[i])

					if i < dimention_count then
						str = str .. ", "
					end
				end

				str = str .. " };"

				return str
			end
		},
		vector_magnitude = {
			prototype = function(name, struct_typename, value_typename, dimention_count)
				return string.format("%s %s_magnitude(%s v)", value_typename, name, struct_typename)
			end,

			impl = function(name, struct_typename, value_typename, dimention_count)
				local str = string.format("return (%s)sqrt(", value_typename)

				for i = 1, dimention_count do
					str = str .. string.format("((%s)v.%s * (%s)v.%s)",
							value_typename, config.vector_dimentions[i],
							value_typename, config.vector_dimentions[i])

					if i < dimention_count then
						str = str .. " + "
					end
				end

				str = str .. ");"

				return str
			end
		},
		vector_normalised = {
			prototype = function(name, struct_typename, value_typename, dimention_count)
				return string.format("%s %s_normalised(%s v)", struct_typename, name, struct_typename)
			end,

			impl = function(name, struct_typename, value_typename, dimention_count)
				local str = string.format("const %s l = %s_magnitude(v);\n", value_typename, name)

				str = str .. get_indent() .. string.format("return l == (%s)0 ? (%s) { ", value_typename, struct_typename)

				for i = 1, dimention_count do
					str = str .. string.format("(%s)0", value_typename)

					if i < dimention_count then
						str = str .. ", "
					end
				end

				str = str .. string.format("} : (%s) { ", struct_typename)

				for i = 1, dimention_count do
					str = str .. string.format("(%s)v.%s / l", value_typename, config.vector_dimentions[i])

					if i < dimention_count then
						str = str .. ", "
					end
				end

				str = str .. "};"

				return str
			end
		},
		vector_dot = {
			prototype = function(name, struct_typename, value_typename, dimention_count)
				return string.format("%s %s_dot(%s a, %s b)", value_typename, name, struct_typename, struct_typename)
			end,

			impl = function(name, struct_typename, value_typename, dimention_count)
				local str = "return ("

				for i = 1, dimention_count do
					str = str .. string.format("(a.%s * b.%s)",
							config.vector_dimentions[i],
							config.vector_dimentions[i])

					if i < dimention_count then
						str = str .. " + "
					end
				end

				str = str .. ");"

				return str
			end
		},
		vector_cross = {
			for_vector = 3,

			prototype = function(name, struct_typename, value_typename, dimention_count)
				return string.format("%s %s_cross(%s a, %s b)", struct_typename, name, struct_typename, struct_typename)
			end,

			impl = function(name, struct_typename, value_typename, dimention_count)
				local x = config.vector_dimentions[1]
				local y = config.vector_dimentions[2]
				local z = config.vector_dimentions[3]
				local indent = get_indent()

				return string.format([[
return make_%s(
%s%s%sa.%s * b.%s - a.%s * b.%s,
%s%s%sa.%s * b.%s - a.%s * b.%s,
%s%s%sa.%s * b.%s - a.%s * b.%s);]], name,
					indent, indent, indent, y, z, z, y,
					indent, indent, indent, z, x, y, z,
					indent, indent, indent, x, y, y, x)
			end
		},
		vector_add = {
			prototype = function(name, struct_typename, value_typename, dimention_count)
				return string.format("%s %s_add(%s a, %s b)", struct_typename, name, struct_typename, struct_typename)
			end,

			impl = function(name, struct_typename, value_typename, dimention_count)
				local str = string.format("return (%s) { ", struct_typename)

				for i = 1, dimention_count do
					str = str .. string.format("a.%s + b.%s",
							config.vector_dimentions[i],
							config.vector_dimentions[i])

					if i < dimention_count then
						str = str .. ", "
					end
				end

				str = str .. " };"

				return str
			end
		},
		vector_sub = {
			prototype = function(name, struct_typename, value_typename, dimention_count)
				return string.format("%s %s_sub(%s a, %s b)", struct_typename, name, struct_typename, struct_typename)
			end,

			impl = function(name, struct_typename, value_typename, dimention_count)
				local str = string.format("return (%s) { ", struct_typename)

				for i = 1, dimention_count do
					str = str .. string.format("a.%s - b.%s",
							config.vector_dimentions[i],
							config.vector_dimentions[i])

					if i < dimention_count then
						str = str .. ", "
					end
				end

				str = str .. " };"

				return str
			end
		},
		vector_mul = {
			prototype = function(name, struct_typename, value_typename, dimention_count)
				return string.format("%s %s_mul(%s a, %s b)", struct_typename, name, struct_typename, struct_typename)
			end,

			impl = function(name, struct_typename, value_typename, dimention_count)
				local str = string.format("return (%s) { ", struct_typename)

				for i = 1, dimention_count do
					str = str .. string.format("a.%s * b.%s",
							config.vector_dimentions[i],
							config.vector_dimentions[i])

					if i < dimention_count then
						str = str .. ", "
					end
				end

				str = str .. " };"

				return str
			end
		},
		vector_div = {
			prototype = function(name, struct_typename, value_typename, dimention_count)
				return string.format("%s %s_div(%s a, %s b)", struct_typename, name, struct_typename, struct_typename)
			end,

			impl = function(name, struct_typename, value_typename, dimention_count)
				local str = string.format("return (%s) { ", struct_typename)

				for i = 1, dimention_count do
					str = str .. string.format("a.%s / b.%s",
							config.vector_dimentions[i],
							config.vector_dimentions[i])

					if i < dimention_count then
						str = str .. ", "
					end
				end

				str = str .. " };"

				return str
			end
		},
		vector_scale = {
			prototype = function(name, struct_typename, value_typename, dimention_count)
				return string.format("%s %s_scale(%s v, %s s)", struct_typename, name, struct_typename, value_typename)
			end,

			impl = function(name, struct_typename, value_typename, dimention_count)
				local str = string.format("return (%s) { ", struct_typename)

				for i = 1, dimention_count do
					str = str .. string.format("v.%s * s",
							config.vector_dimentions[i])

					if i < dimention_count then
						str = str .. ", "
					end
				end

				str = str .. " };"

				return str
			end
		}
	},

	matrix = {
		matrix_construct = {
			prototype = function(name, struct_typename, value_typename, matrix)
				return string.format("%s make_%s(%s d)", struct_typename, name, value_typename)
			end,

			impl = function(name, struct_typename, value_typename, matrix)
				local str = string.format("%s r;\n", struct_typename)

				local indent = get_indent()

				str = str .. indent .. string.format("for (int x = 0; x < %d; x++) {\n", matrix.size)
				str = str .. indent .. indent .. string.format("for (int y = 0; y < %d; y++) {\n", matrix.size)
				str = str .. indent .. indent .. indent .. string.format("r.%s = (%s)0;\n", matrix_at(matrix, "x", "y"), value_typename)
				str = str .. indent .. indent .. "}\n" .. indent .. "}\n\n"

				for i = 1, matrix.size do
					str = str .. indent .. string.format("r.%s = d;\n", matrix_at(matrix, i - 1, i - 1))
				end

				str = str .. "\n" .. indent .. "return r;"

				return str
			end
		},

		matrix_identity = {
			prototype = function(name, struct_typename, value_typename, matrix)
				return string.format("%s %s_identity()", struct_typename, name)
			end,

			impl = function(name, struct_typename, value_typename, matrix)
				return string.format("return make_%s((%s)1);", name, value_typename)
			end
		},

		matrix_mul = {
			prototype = function(name, struct_typename, value_typename, matrix)
				return string.format("%s %s_mul(%s a, %s b)", struct_typename, name, struct_typename, struct_typename)
			end,

			impl = function(name, struct_typename, value_typename, matrix)
				local str = string.format("%s r = make_%s((%s)1);\n\n", struct_typename, name, value_typename)

				local indent = get_indent()

				for row = 1, matrix.size do
					for col = 1, matrix.size do
						str = str .. indent .. string.format("r.%s = ", matrix_at(matrix, row - 1, col - 1))

						for e = 1, matrix.size do
							str = str .. string.format("a.%s * b.%s", matrix_at(matrix, e - 1, row - 1), matrix_at(matrix, col - 1, e - 1))

							if e < matrix.size then
								str = str .. " + "
							end
						end

						str = str .. ";\n"
					end
				end

				return str .. "\n" .. indent .. "return r;";
			end
		},

		matrix_translate = {
			min_size = 4,

			prototype = function(name, struct_typename, value_typename, matrix)
				local vector_typename = struct_name(find_vector(3, matrix.typename))

				return string.format("%s %s_translate(%s m, %s v)", struct_typename, name, struct_typename, vector_typename)
			end,

			impl = function(name, struct_typename, value_typename, matrix)
				local str = string.format("%s r = make_%s((%s)1);\n\n", struct_typename, name, value_typename)

				local indent = get_indent()

				for i = 1, 3 do
					str = str .. indent .. string.format("r.%s = v.%s;\n", matrix_at(matrix, 3, i - 1), config.vector_dimentions[i])
				end

				return str .. "\n" .. indent .. string.format("return %s_mul(m, r);", name)
			end
		},

		matrix_scale = {
			min_size = 3,

			prototype = function(name, struct_typename, value_typename, matrix)
				local vector_typename = struct_name(find_vector(3, matrix.typename))

				return string.format("%s %s_scale(%s m, %s v)", struct_typename, name, struct_typename, vector_typename)
			end,

			impl = function(name, struct_typename, value_typename, matrix)
				local str = string.format("%s r = make_%s((%s)1);\n\n", struct_typename, name, value_typename)

				local indent = get_indent()

				for i = 1, 3 do
					str = str .. indent .. string.format("r.%s = v.%s;\n", matrix_at(matrix, i - 1, i - 1), config.vector_dimentions[i])
				end

				return str .. "\n" .. indent .. string.format("return %s_mul(m, r);", name)
			end
		},

		matrix_rotate = {
			min_size = 3,

			prototype = function(name, struct_typename, value_typename, matrix)
				local vector_typename = struct_name(find_vector(3, matrix.typename))

				return string.format("%s %s_rotate(%s m, %s a, %s v)", struct_typename, name, struct_typename, value_typename, vector_typename)
			end,

			impl = function(name, struct_typename, value_typename, matrix)
				local str = string.format("%s r = make_%s((%s)1);\n\n", struct_typename, name, value_typename)

				local indent = get_indent()

				str = str .. string.format([[
%sconst %s c = (%s)cos((double)a);
%sconst %s s = (%s)sin((double)a);

%sconst %s omc = (%s)1 - c;

%sconst %s x = v.%s;
%sconst %s y = v.%s;
%sconst %s z = v.%s;

]],
				indent, value_typename, value_typename, indent, value_typename, value_typename,
				indent, value_typename, value_typename,
				indent, value_typename, config.vector_dimentions[1],
				indent, value_typename, config.vector_dimentions[2],
				indent, value_typename, config.vector_dimentions[3])

				str = str .. indent .. string.format("r.%s = x * x * omc + c;\n", matrix_at(matrix, 0, 0))
				str = str .. indent .. string.format("r.%s = y * x * omc + z * s;\n", matrix_at(matrix, 0, 1))
				str = str .. indent .. string.format("r.%s = x * z * omc - y * s;\n", matrix_at(matrix, 0, 2))
				str = str .. indent .. string.format("r.%s = x * y * omc - z * s;\n", matrix_at(matrix, 1, 0))
				str = str .. indent .. string.format("r.%s = y * y * omc + c;\n", matrix_at(matrix, 1, 1))
				str = str .. indent .. string.format("r.%s = y * z * omc + x * s;\n", matrix_at(matrix, 1, 2))
				str = str .. indent .. string.format("r.%s = x * z * omc + y * s;\n", matrix_at(matrix, 2, 0))
				str = str .. indent .. string.format("r.%s = y * z * omc - x * s;\n", matrix_at(matrix, 2, 1))
				str = str .. indent .. string.format("r.%s = z * z * omc + c;\n", matrix_at(matrix, 2, 2))

				return str .. "\n" .. indent .. string.format("return %s_mul(m, r);", name)
			end
		},

		matrix_ortho = {
			min_size = 4,

			prototype = function(name, struct_typename, value_typename, matrix)
				local vector_typename = struct_name(find_vector(3, matrix.typename))

				return string.format("%s %s_orth(%s l, %s r, %s b, %s t, %s n, %s f)", struct_typename, name,
					value_typename,
					value_typename,
					value_typename,
					value_typename,
					value_typename,
					value_typename)
			end,

			impl = function(name, struct_typename, value_typename, matrix)
				local str = string.format("%s res = make_%s((%s)1);\n\n", struct_typename, name, value_typename)

				local indent = get_indent()

				str = str .. indent .. string.format("res.%s = (%s)2 / (r - l);\n", matrix_at(matrix, 0, 0), value_typename)
				str = str .. indent .. string.format("res.%s = (%s)2 / (t - b);\n", matrix_at(matrix, 1, 1), value_typename)
				str = str .. indent .. string.format("res.%s = (%s)2 / (n - f);\n\n", matrix_at(matrix, 2, 2), value_typename)

				str = str .. indent .. string.format("res.%s = (l + r) / (l - r);\n", matrix_at(matrix, 3, 0))
				str = str .. indent .. string.format("res.%s = (b + t) / (b - t);\n", matrix_at(matrix, 3, 1))
				str = str .. indent .. string.format("res.%s = (f + n) / (f - n);\n", matrix_at(matrix, 3, 2))

				return str .. "\n" .. indent .. string.format("return res;", name)
			end
		},

		matrix_pers = {
			min_size = 4,

			prototype = function(name, struct_typename, value_typename, matrix)
				local vector_typename = struct_name(find_vector(3, matrix.typename))

				return string.format("%s %s_pers(%s fov, %s asp, %s n, %s f)", struct_typename, name,
					value_typename,
					value_typename,
					value_typename,
					value_typename)
			end,

			impl = function(name, struct_typename, value_typename, matrix)
				local str = string.format("%s r = make_%s((%s)1);\n\n", struct_typename, name, value_typename)

				local indent = get_indent()

				str = str .. string.format([[
%sconst %s q = (%s)1 / (%s)tan(torad((double)fov) / 2.0);
%sconst %s a = q / asp;
%sconst %s b = (n + f) / (n - f);
%sconst %s c = ((%s)2 * n * f) / (n - f);

]],
					indent, value_typename, value_typename, value_typename,
					indent, value_typename,
					indent, value_typename,
					indent, value_typename, value_typename)

				str = str .. indent .. string.format("r.%s = a;\n",      matrix_at(matrix, 0, 0))
				str = str .. indent .. string.format("r.%s = q;\n",      matrix_at(matrix, 1, 1))
				str = str .. indent .. string.format("r.%s = b;\n",      matrix_at(matrix, 2, 2))
				str = str .. indent .. string.format("r.%s = (%s)-1;\n", matrix_at(matrix, 2, 3), value_typename)
				str = str .. indent .. string.format("r.%s = c;\n",      matrix_at(matrix, 3, 2))

				return str .. "\n" .. indent .. string.format("return r;", name)
			end
		},

		matrix_lookat = {
			min_size = 4,

			prototype = function(name, struct_typename, value_typename, matrix)
				local vector_typename = struct_name(find_vector(3, matrix.typename))
				return string.format("%s %s_lookat(%s c, %s o, %s u)", struct_typename, name,
					vector_typename, vector_typename, vector_typename)
			end,

			impl = function(name, struct_typename, value_typename, matrix)
				local x = config.vector_dimentions[1]
				local y = config.vector_dimentions[2]
				local z = config.vector_dimentions[3]

				local vector_typename = struct_name(find_vector(3, matrix.typename))
				local normalise_name = string.match(function_generators.vector.vector_normalised.prototype(
					find_vector(3, matrix.typename), vector_typename, matrix.typename, 3), " (.*)%(")
				local vector_sub_name = string.match(function_generators.vector.vector_sub.prototype(
					find_vector(3, matrix.typename), vector_typename, matrix.typename, 3), " (.*)%(")
				local cross_name = string.match(function_generators.vector.vector_cross.prototype(
					find_vector(3, matrix.typename), vector_typename, matrix.typename, 3), " (.*)%(")
				local dot_name = string.match(function_generators.vector.vector_dot.prototype(
					find_vector(3, matrix.typename), vector_typename, matrix.typename, 3), " (.*)%(")


				local str = string.format("%s r = make_%s((%s)1);\n\n", struct_typename, name, value_typename)

				local indent = get_indent()

				str = str .. indent .. string.format("const %s f = %s(%s(o, c));\n",
					vector_typename, normalise_name, vector_sub_name);

				str = str .. indent .. string.format("u = %s(u);\n", normalise_name)
				str = str .. indent .. string.format("const %s s = %s(%s(f, u));\n", vector_typename, normalise_name, cross_name)
				str = str .. indent .. string.format("u = %s(s, f);\n\n", cross_name);

				str = str .. indent .. string.format("r.%s = s.%s;\n",  matrix_at(matrix, 0, 0), x)
				str = str .. indent .. string.format("r.%s = s.%s;\n",  matrix_at(matrix, 1, 0), y)
				str = str .. indent .. string.format("r.%s = s.%s;\n",  matrix_at(matrix, 2, 0), z)
				str = str .. indent .. string.format("r.%s = u.%s;\n",  matrix_at(matrix, 0, 1), x)
				str = str .. indent .. string.format("r.%s = u.%s;\n",  matrix_at(matrix, 1, 1), y)
				str = str .. indent .. string.format("r.%s = u.%s;\n",  matrix_at(matrix, 2, 1), z)
				str = str .. indent .. string.format("r.%s = -f.%s;\n", matrix_at(matrix, 0, 2), x)
				str = str .. indent .. string.format("r.%s = -f.%s;\n", matrix_at(matrix, 1, 2), y)
				str = str .. indent .. string.format("r.%s = -f.%s;\n", matrix_at(matrix, 2, 2), z)

				str = str .. indent .. string.format("r.%s = -%s(s, c);\n", matrix_at(matrix, 3, 0), dot_name)
				str = str .. indent .. string.format("r.%s = -%s(u, c);\n", matrix_at(matrix, 3, 1), dot_name)
				str = str .. indent .. string.format("r.%s = %s(f, c);\n\n",  matrix_at(matrix, 3, 2), dot_name)

				return str .. indent .. "return r;"
			end
		}
	}
}

function find_vector(dimentions, typename)
	for k, v in pairs(config.vectors) do
		if v.dimentions == dimentions and v.typename == typename then
			return k;
		end
	end

	assert(false, string.format("No %d-dimentional vector for `%s' vector defined.", dimentions, typename))
end

function get_indent()
	if config.indent_style == "tabs" then
		return "\t"
	else
		local str = ""
		for i = 1, config.indent_size do
			str = str .. " "
		end
		return str
	end
end

function write_indent(file)
	if config.indent_style == "tabs" then
		file:write("\t")
	else
		for i = 1, config.indent_size do
			file:write(" ")
		end
	end
end

function struct_name(n)
	if not config.typedef_structs then
		return string.format("struct %s", n)
	end

	return n;
end

function generate_struct(file, name, props)
	if config.typedef_structs then
		file:write("typedef struct {\n");
	else
		file:write(string.format("struct %s {\n", name))
	end

	for i, prop in ipairs(props) do
		write_indent(file)
		file:write(string.format("%s %s;\n", prop.typename, prop.name))
	end

	file:write("}")

	if config.typedef_structs then
		file:write(" ")
		file:write(name)
	end

	file:write(";\n\n")
end

function matrix_at(matrix, x, y)
	if matrix.major == "row" then
		return string.format("m[%s][%s]", tostring(y), tostring(x))
	else
		return string.format("m[%s][%s]", tostring(x), tostring(y))
	end
end

function generate_header(file)
	file:write("#pragma once\n\n")

	file:write("#ifndef pi\n#define pi 3.14159265358f\n#endif\n\n")

	if config.typedef_integers then
		file:write("#include <stdint.h>\n\n")
		file:write("typedef int8_t   i8;\n")
		file:write("typedef int16_t  i16;\n")
		file:write("typedef int32_t  i32;\n")
		file:write("typedef int64_t  i64;\n")
		file:write("typedef uint8_t  u8;\n")
		file:write("typedef uint16_t u16;\n")
		file:write("typedef uint32_t u32;\n")
		file:write("typedef uint64_t u64;\n\n")
	end

	for gname, gen in pairs(function_generators.global) do
		file:write(string.format("%s;\n", gen.prototype()))
	end

	file:write("\n")

	for k, v in pairs(config.vectors) do
		local props = {}
		for i = 1, v.dimentions do
			props[#props + 1] = { typename = v.typename, name = config.vector_dimentions[i] }
		end
		generate_struct(file, k, props)

		local struct_typename = struct_name(k);

		for gname, gen in pairs(function_generators.vector) do
			if gen.for_vector ~= nil and gen.for_vector ~= v.dimentions then
				goto continue
			end

			file:write(string.format("%s;\n", gen.prototype(k, struct_typename, v.typename, v.dimentions)))

		::continue::
		end

		file:write("\n")
	end

	for k, v in pairs(config.matrices) do
		local props = {
			{
				typename = v.typename,
				name = matrix_at(v, v.size, v.size)
			}
		}

		generate_struct(file, k, props)

		local struct_typename = struct_name(k)

		for gname, gen in pairs(function_generators.matrix) do
			if gen.min_size ~= nil and v.size < gen.min_size then
				goto continue
			end

			file:write(string.format("%s;\n", gen.prototype(k, struct_typename, v.typename, v)))

			::continue::
		end

		file:write("\n")
	end
end

function generate_impl(file)
	file:write(string.format("/* Implementation */\n#ifdef %s\n\n", config.impl_def))

	file:write("#include <math.h>\n\n")

	for gname, gen in pairs(function_generators.global) do
		file:write(string.format("%s {\n", gen.prototype()))
		write_indent(file)
		file:write(string.format("%s\n}\n\n", gen.impl()))
	end

	for k, v in pairs(config.vectors) do
		local struct_typename = struct_name(k);

		for gname, gen in pairs(function_generators.vector) do
			if gen.for_vector ~= nil and gen.for_vector ~= v.dimentions then
				goto continue
			end


			file:write(string.format("%s {\n", gen.prototype(k, struct_typename, v.typename, v.dimentions)))
			write_indent(file);

			file:write(string.format("%s\n", gen.impl(k, struct_typename, v.typename, v.dimentions)))

			file:write("}\n\n")

			::continue::
		end
	end

	for k, v in pairs(config.matrices) do
		local struct_typename = struct_name(k);

		for gname, gen in pairs(function_generators.matrix) do
			if gen.min_size ~= nil and v.size < gen.min_size then
				goto continue
			end

			file:write(string.format("%s {\n", gen.prototype(k, struct_typename, v.typename, v)))
			write_indent(file);

			file:write(string.format("%s\n", gen.impl(k, struct_typename, v.typename, v)))

			file:write("}\n\n")

			::continue::
		end
	end

	file:write(string.format("#endif /* %s */\n", config.impl_def))
end

function generate()
	local file = io.open(config.outfile, "w")	

	generate_header(file)
	generate_impl(file)

	file:close()
end

generate()
