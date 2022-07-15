package com.sarahisweird.foodlist

import io.ktor.client.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.Serializable
import kotlinx.serialization.builtins.ListSerializer
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import kotlin.coroutines.cancellation.CancellationException

class RestException(val responseCode: Int, reason: String) : Exception(reason)

@Serializable
enum class StorageType {
    SHELF,
    REFRIGERATOR,
    FREEZER
}

@Serializable
data class PartialStorageUnit(
    val id: Long,
    val name: String,
    val description: String,
    val storageType: StorageType
)

@Serializable
data class StorageUnit(
    val id: Long,
    val name: String,
    val description: String,
    val storageType: StorageType,
    val shelves: @Serializable List<PartialShelf>,
)

@Serializable
data class PartialShelf(
    val id: Long,
    val name: String,
    val description: String,
    val ofStorageUnit: Long,
)

@Serializable
data class Shelf(
    val id: Long,
    val name: String,
    val description: String,
    val ofStorageUnit: Long,
    val items: @Serializable List<Item>
)

@Serializable
data class Item(
    val id: Long,
    val name: String,
    val description: String,
)

open class RestService {
    protected val json = Json

    protected suspend fun checkResponseOkOrThrow(response: HttpResponse) {
        if (!listOf(HttpStatusCode.OK, HttpStatusCode.NoContent).contains(response.status)) {
            throw RestException(response.status.value, response.bodyAsText())
        }
    }
}

class StorageUnitService : RestService() {
    private var apiUrl = "http://192.168.178.26:8080"

    private val httpClient = HttpClient {
        install(ContentNegotiation) {
            json()
        }
    }

    fun createShelfService(storageUnitId: Long): ShelfService {
        return ShelfService(storageUnitId, apiUrl, httpClient)
    }

    suspend fun getStorageUnits(): List<PartialStorageUnit> {
        val response = httpClient.get("$apiUrl/api/storageUnits").bodyAsText()

        return Json.decodeFromString(ListSerializer(PartialStorageUnit.serializer()), response)
    }

    @Throws(CancellationException::class, RestException::class)
    suspend fun createStorageUnit(name: String, description: String, storageType: StorageType): PartialStorageUnit {
        @Serializable
        data class CreateStorageUnitDTO(
            val name: String,
            val description: String,
            val storageType: StorageType,
        )

        val response = httpClient.post("$apiUrl/api/storageUnits") {
            contentType(ContentType.Application.Json)
            setBody(CreateStorageUnitDTO(name, description, storageType))
        }

        checkResponseOkOrThrow(response)

        return Json.decodeFromString(PartialStorageUnit.serializer(), response.bodyAsText())
    }

    suspend fun getStorageUnit(id: Long): StorageUnit {
        val response = httpClient.get("$apiUrl/api/storageUnits/$id").bodyAsText()

        return Json.decodeFromString(response)
    }

    @Throws(CancellationException::class, RestException::class)
    suspend fun modifyStorageUnit(id: Long, name: String?, description: String?, storageType: StorageType?): PartialStorageUnit {
        @Serializable
        data class ModifyStorageUnitDTO(
            val name: String?,
            val description: String?,
            val storageType: StorageType?,
        )

        val response = httpClient.patch("$apiUrl/api/storageUnits/$id") {
            contentType(ContentType.Application.Json)
            setBody(ModifyStorageUnitDTO(name, description, storageType))
        }

        checkResponseOkOrThrow(response)

        return Json.decodeFromString(PartialStorageUnit.serializer(), response.bodyAsText())
    }

    @Throws(CancellationException::class, RestException::class)
    suspend fun deleteStorageUnit(id: Long) {
        val response = httpClient.delete("$apiUrl/api/storageUnits/$id")

        checkResponseOkOrThrow(response)
    }
}

class ShelfService(
    val storageUnitId: Long,
    private val apiUrl: String,
    private val httpClient: HttpClient
) : RestService() {
    fun createItemService(shelfId: Long): ItemService =
        ItemService(storageUnitId, shelfId, apiUrl, httpClient)

    @Throws(CancellationException::class, RestException::class)
    suspend fun getShelves(): List<PartialShelf> {
        val response = httpClient.get("$apiUrl/api/storageUnits/$storageUnitId/shelves")

        checkResponseOkOrThrow(response)

        return Json.decodeFromString(ListSerializer(PartialShelf.serializer()), response.bodyAsText())
    }

    @Throws(CancellationException::class, RestException::class)
    suspend fun createShelf(name: String, description: String): PartialShelf {
        @Serializable
        data class CreateShelfDTO(
            val name: String,
            val description: String,
        )

        val response = httpClient.post("$apiUrl/api/storageUnits/$storageUnitId/shelves") {
            contentType(ContentType.Application.Json)
            setBody(CreateShelfDTO(name, description))
        }

        checkResponseOkOrThrow(response)

        return Json.decodeFromString(PartialShelf.serializer(), response.bodyAsText())
    }

    @Throws(CancellationException::class, RestException::class)
    suspend fun getShelf(id: Long): Shelf {
        val response = httpClient.get("$apiUrl/api/storageUnits/$storageUnitId/shelves/$id")

        checkResponseOkOrThrow(response)

        return Json.decodeFromString(Shelf.serializer(), response.bodyAsText())
    }

    @Throws(CancellationException::class, RestException::class)
    suspend fun modifyShelf(id: Long, name: String?, description: String?): PartialShelf? {
        @Serializable
        data class ModifyShelfDTO(
            val name: String?,
            val description: String?,
        )

        val response = httpClient.patch("$apiUrl/api/storageUnits/$storageUnitId/shelves/$id") {
            contentType(ContentType.Application.Json)
            setBody(ModifyShelfDTO(name, description))
        }

        checkResponseOkOrThrow(response)

        if (response.status == HttpStatusCode.NoContent) {
            return null
        }

        return Json.decodeFromString(PartialShelf.serializer(), response.bodyAsText())
    }

    @Throws(CancellationException::class, RestException::class)
    suspend fun deleteShelf(id: Long) {
        val response = httpClient.delete("$apiUrl/api/storageUnits/$storageUnitId/shelves/$id")

        checkResponseOkOrThrow(response)
    }
}

class ItemService(
    val storageUnitId: Long,
    val shelfId: Long,
    private val apiUrl: String,
    private val httpClient: HttpClient
) : RestService() {
    @Throws(CancellationException::class, RestException::class)
    suspend fun getItems(): List<Item> {
        val response = httpClient.get("$apiUrl/api/storageUnits/$storageUnitId/shelves/$shelfId/items")

        checkResponseOkOrThrow(response)

        return Json.decodeFromString(ListSerializer(Item.serializer()), response.bodyAsText())
    }

    @Throws(CancellationException::class, RestException::class)
    suspend fun createItem(name: String, description: String): Item {
        @Serializable
        data class CreateItemDTO(
            val name: String,
            val description: String,
        )

        val response = httpClient.post("$apiUrl/api/storageUnits/$storageUnitId/shelves/$shelfId/items") {
            contentType(ContentType.Application.Json)
            setBody(CreateItemDTO(name, description))
        }

        checkResponseOkOrThrow(response)

        return Json.decodeFromString(Item.serializer(), response.bodyAsText())
    }

    @Throws(CancellationException::class, RestException::class)
    suspend fun getItem(id: Long): Item {
        val response = httpClient.get("$apiUrl/api/storageUnits/$storageUnitId/shelves/$shelfId/items/$id")

        checkResponseOkOrThrow(response)

        return Json.decodeFromString(Item.serializer(), response.bodyAsText())
    }

    @Throws(CancellationException::class, RestException::class)
    suspend fun modifyItem(id: Long, name: String?, description: String?): Item {
        @Serializable
        data class ModifyItemDTO(
            val name: String?,
            val description: String?,
        )

        val response = httpClient.patch("$apiUrl/api/storageUnits/$storageUnitId/shelves/$shelfId/items/$id") {
            contentType(ContentType.Application.Json)
            setBody(ModifyItemDTO(name, description))
        }

        checkResponseOkOrThrow(response)

        return Json.decodeFromString(Item.serializer(), response.bodyAsText())
    }

    @Throws(CancellationException::class, RestException::class)
    suspend fun deleteItem(id: Long) {
        val response = httpClient.delete("$apiUrl/api/storageUnits/$storageUnitId/shelves/$shelfId/items/$id")

        checkResponseOkOrThrow(response)
    }
}