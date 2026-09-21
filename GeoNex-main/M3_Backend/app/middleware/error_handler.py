"""
app/middleware/error_handler.py

Centralized API Error Response Handler (Phase 28).

Standardized JSON Error Format:
{
    "success": false,
    "error": {
        "code": "REPORT_NOT_FOUND",
        "message": "Field report not found",
        "details": null
    }
}
"""

from fastapi import Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException


async def custom_http_exception_handler(request: Request, exc: StarletteHTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error": {
                "code": f"HTTP_{exc.status_code}",
                "message": exc.detail,
                "details": None,
            },
        },
    )


async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "success": False,
            "error": {
                "code": "VALIDATION_ERROR",
                "message": "Input validation failed",
                "details": exc.errors(),
            },
        },
    )
