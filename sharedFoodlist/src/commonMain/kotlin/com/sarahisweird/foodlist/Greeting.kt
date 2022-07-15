package com.sarahisweird.foodlist

import io.ktor.client.*
import io.ktor.client.request.*
import io.ktor.client.statement.*

class Greeting {
    private val client = HttpClient()

    suspend fun getHtml(): String {
        val response = client.get("https://ktor.io/docs")

        return response.bodyAsText()
    }
}