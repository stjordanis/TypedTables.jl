"""
    cell_type(InType, [name])

Returns a subtype of `AbstractCell` that is similar to `InType` but optionally
with modified fieldname `name`. The element type of the cell remains undefined.
"""
cell_type{C<:Union{AbstractCell, AbstractColumn}}(::Type{C}) = cell_type(C, name(C))

# Defaults to `Cell`
@pure cell_type{C<:Union{AbstractCell, AbstractColumn}}(::Type{C}, newname::Symbol) = Cell{newname}

"""
    column_type(InType, [name])

Returns a subtype of `AbstractColumn` that is similar to `InType` but optionally
with modified fieldname `name`. The storage type of the column remains undefined.
"""
column_type{C<:Union{AbstractCell, AbstractColumn}}(::Type{C}) = AbstractColumn(C, name(C))

# Defaults to `Cell`
@pure column_type{C<:Union{AbstractCell, AbstractColumn}}(::Type{C}, newname::Symbol) = Cell{newname}

"""
    row_type(InType, [names])

Returns a subtype of `AbstractRow` that is similar to `InType` but optionally
with modified fieldname `names = (name1, name2, ...)`. The element types remain
undefined.
"""
row_type{R<:Union{AbstractRow, AbstractTable}}(::Type{R}) = row_type(R, names(R))

# Defaults to `Row`
@pure row_type{R<:Union{AbstractRow, AbstractTable}}(::Type{R}, newnames::Tuple{Vararg{Symbol}}) = Row{newnames}

"""
    table_type(InType, [names])

Returns a subtype of `AbstractTable` that is similar to `InType` but optionally
with modified fieldname `names = (name1, name2, ...)`. The storage types remain
undefined.
"""
table_type{Tbl<:Union{AbstractRow, AbstractTable}}(::Type{Tbl}) = table_type(R, names(R))

# Defaults to `Table`
@pure table_type{Tbl<:Union{AbstractRow, AbstractTable}}(::Type{Tbl}, newnames::Tuple{Vararg{Symbol}}) = Table{newnames}



#
# Default to sensible storage for large amounts of data
#

@inline makestorage{T}(::Type{T}) = Vector{T}()
@inline makestorage{N<:Nullable}(::Type{N}) = NullableVector{eltype(N)}()
@inline makestorage(::Type{Bool}) = BitVector()

@inline makestorage{T}(::Type{T}, len::Integer) = Vector{T}(len)
@inline makestorage{N<:Nullable}(::Type{N}, len::Integer) = NullableVector{eltype(N)}(len)
@inline makestorage(::Type{Bool}, len::Integer) = BitVector(len)

@generated function makestorages{Types<:Tuple}(::Type{Types})
    exprs = [t -> :($t()) for t ∈ Types.parameters]
    return quote
        $(Expr(:meta, :inline))
        $(Expr(:tuple, exprs...))
    end
end

@generated function makestorages{Types<:Tuple}(::Type{Types}, len::Integer)
    exprs = [t -> :($t(len)) for t ∈ Types.parameters]
    return quote
        $(Expr(:meta, :inline))
        $(Expr(:tuple, exprs...))
    end
end
