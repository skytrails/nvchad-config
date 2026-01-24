<template>
  <div class="ele-body game-page">
    <el-card shadow="hover" class="search-card">
      <!-- 搜索表单 -->
      <el-form
        :model="where"
        label-width="70px"
        class="ele-form-search"
        @keyup.enter.native="reload"
        @submit.native.prevent
        size="small"
      >
        <el-row :gutter="16">
          <el-col :lg="4" :md="8">
            <el-form-item label="游戏ID">
              <el-input clearable v-model="where.gameId" placeholder="请输入游戏ID" />
            </el-form-item>
          </el-col>

          <el-col :lg="4" :md="8">
            <el-form-item label="游戏名">
              <el-input clearable v-model="where.gameName" placeholder="请输入游戏名" />
            </el-form-item>
          </el-col>

          <el-col :lg="6" :md="8" class="form-actions">
            <el-button
              type="primary"
              icon="el-icon-search"
              @click="reload"
              :disabled="!permission.includes('sys:game:index')"
            >
              查询
            </el-button>
            <el-button
              icon="el-icon-refresh"
              @click="reset"
              :disabled="!permission.includes('sys:game:index')"
            >
              重置
            </el-button>
          </el-col>
        </el-row>
      </el-form>
    </el-card>

    <el-card shadow="never" class="table-card">
      <ele-pro-table
        ref="table"
        :where="where"
        :datasource="url"
        :columns="columns"
        :selection.sync="selection"
        size="small"
      >
        <!-- 表头工具栏 -->
        <template slot="toolbar">
          <el-button
            type="primary"
            icon="el-icon-plus"
            size="small"
            @click="openEdit(null)"
            :disabled="!permission.includes('sys:game:add')"
          >
            添加游戏
          </el-button>
        </template>

        <!-- 配置状态 -->
        <template slot="denuvo" slot-scope="{ row }">
          <div class="tag-group">
            <el-tag size="mini" :type="row.denuvo ? 'success' : 'info'">
              D加密 {{ row.denuvo ? '是' : '否' }}
            </el-tag>
            <el-tag size="mini" :type="row.drm ? 'success' : 'info'">
              DRM {{ row.drm ? '是' : '否' }}
            </el-tag>
            <el-tag size="mini" :type="row.online ? 'success' : 'info'">
              联机 {{ row.online ? '是' : '否' }}
            </el-tag>
            <el-tag size="mini" :type="row.online_plus ? 'success' : 'info'">
              补丁 {{ row.online_plus ? '是' : '否' }}
            </el-tag>
          </div>
        </template>

        <!-- 游戏封面 -->
        <template slot="imageUrl" slot-scope="{ row }">
          <el-avatar
            shape="square"
            :size="56"
            :src="row.imageUrl"
            class="cover-img"
          />
        </template>

        <!-- 状态 -->
        <template slot="status" slot-scope="{ row }">
          <el-tag
            size="mini"
            :type="row.status === 1 ? 'success' : 'info'"
            effect="dark"
          >
            {{ row.status === 1 ? '启用' : '停用' }}
          </el-tag>
        </template>

        <!-- 操作 -->
        <template slot="action" slot-scope="{ row }">
          <div class="action-buttons">
            <el-button
              type="text"
              icon="el-icon-edit"
              @click="openEdit(row)"
              :disabled="!permission.includes('sys:game:edit')"
            >
              编辑
            </el-button>

            <el-popconfirm title="确认删除该游戏？" @confirm="remove(row)">
              <el-button
                type="text"
                icon="el-icon-delete"
                slot="reference"
                class="danger"
                :disabled="!permission.includes('sys:game:delete')"
              >
                删除
              </el-button>
            </el-popconfirm>
          </div>
        </template>
      </ele-pro-table>
    </el-card>

    <!-- 编辑弹窗 -->
    <events-edit
      v-if="showEdit"
      :visible="showEdit"
      :data="current"
      @close="showEdit = false"
      @done="reload"
    />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import EventsEdit from "./events-edit";

export default {
  name: "CfEvents",
  components: { EventsEdit },
  computed: {
    ...mapGetters(["permission"]),
  },
  data() {
    return {
      url: "/game/list",
      where: {},
      selection: [],
      current: null,
      showEdit: false,
      columns: [
        { prop: "gameId", label: "游戏ID", width: 140, align: "center" },
        { prop: "gameName", label: "游戏名称", minWidth: 200 },
        { prop: "denuvo", label: "配置状态", slot: "denuvo", minWidth: 220 },
        { prop: "status", label: "状态", slot: "status", width: 100, align: "center" },
        { prop: "createTime", label: "创建时间", sortable: "custom", minWidth: 160 },
        { prop: "updateTime", label: "更新时间", sortable: "custom", minWidth: 160 },
        {
          columnKey: "action",
          label: "操作",
          slot: "action",
          width: 140,
          fixed: "right",
        },
      ],
    };
  },
  methods: {
    reload() {
      this.showEdit = false;
      this.$refs.table.reload();
    },
    reset() {
      this.where = {};
      this.reload();
    },
    openEdit(row) {
      this.current = row || { status: 1 };
      this.showEdit = true;
    },
    remove(row) {
      const loading = this.$loading({ lock: true });
      this.$http
        .post("/cfEvents/delete", [row.id])
        .then(() => {
          loading.close();
          this.$message.success("删除成功");
          this.reload();
        })
        .catch((e) => {
          loading.close();
          this.$message.error(e.message);
        });
    },
  },
};
</script>

<style scoped>
.game-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.search-card {
  padding-bottom: 4px;
}

.form-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.table-card {
  padding: 4px;
}

.tag-group {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.cover-img {
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15);
}

.action-buttons {
  display: flex;
  gap: 8px;
  justify-content: center;
}

.action-buttons .danger {
  color: #f56c6c;
}
</style>

