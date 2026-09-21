import React from 'react';

export function Button({
  children,
  variant = 'primary',
  size = 'md',
  icon: Icon = null,
  active = false,
  className = '',
  disabled = false,
  ...props
}) {
  const baseStyles = 'inline-flex items-center justify-center font-medium rounded-lg transition-all duration-150 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-sky-500 focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none cursor-pointer select-none';

  let variantStyles = 'bg-sky-600 hover:bg-sky-700 active:bg-sky-800 text-white shadow-xs border border-transparent';

  if (variant === 'secondary') {
    variantStyles = 'bg-white hover:bg-slate-50 active:bg-slate-100 text-slate-700 border border-slate-200 shadow-xs hover:border-slate-300';
  } else if (variant === 'outline') {
    variantStyles = 'bg-transparent hover:bg-sky-50 active:bg-sky-100 text-sky-700 border border-sky-300';
  } else if (variant === 'ghost') {
    variantStyles = 'bg-transparent hover:bg-slate-100 active:bg-slate-200 text-slate-600 hover:text-slate-900 border border-transparent';
  } else if (variant === 'danger') {
    variantStyles = 'bg-rose-600 hover:bg-rose-700 active:bg-rose-800 text-white shadow-xs border border-transparent';
  } else if (variant === 'dark') {
    variantStyles = 'bg-slate-800 hover:bg-slate-900 active:bg-slate-950 text-white shadow-xs border border-slate-700';
  }

  if (active) {
    variantStyles += ' ring-2 ring-sky-500 ring-offset-1 bg-sky-50 text-sky-800 border-sky-300';
  }

  const sizeStyles = size === 'xs'
    ? 'px-2 py-0.5 text-[11px] gap-1'
    : size === 'sm'
      ? 'px-2.5 py-1 text-xs gap-1.5'
      : size === 'lg'
        ? 'px-4 py-2 text-sm gap-2 font-semibold'
        : 'px-3 py-1.5 text-xs font-medium gap-1.5';

  return (
    <button
      disabled={disabled}
      className={`${baseStyles} ${variantStyles} ${sizeStyles} ${className}`}
      {...props}
    >
      {Icon && <Icon className={size === 'xs' ? 'w-3 h-3 shrink-0' : 'w-3.5 h-3.5 shrink-0'} aria-hidden="true" />}
      {children}
    </button>
  );
}
